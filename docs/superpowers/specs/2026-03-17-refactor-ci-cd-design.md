# Refactor CI/CD Pipeline

## Problem

Each service template (go, node, python) ships an identical `ci-cd.yml` with two jobs (`build-and-push`, `deploy`). The workflow has six issues:

1. **Duplicated env mapping**: Branch-to-environment logic repeated in 4 separate if/else blocks (SSH key, inventory IP, traefik host, deploy vars)
2. **Inline Ansible playbook**: 20+ line heredoc generated each run — hard to read, can't lint, can't customize
3. **No test stage**: Broken code goes straight to build and deploy
4. **No environment protection**: Anyone pushing to `main` deploys to production with no gate
5. **Image tag collision**: All branches push `:latest`, so a `test` push overwrites what `main` deployed
6. **Slow pipeline**: Ansible installed fresh every run, no dependency caching

## Design Priorities

- **Simplicity**: One workflow file per template, linear job flow, minimal moving parts
- **Fast feedback**: Dependency caching on every job, job timeouts to catch hangs

## Pipeline Structure

Single `ci-cd.yml` rewritten as a 4-job linear pipeline:

```
prepare ──→ test ──→ build-and-push ──→ deploy
```

| Job | Purpose | Depends on | Timeout |
|-----|---------|-----------|---------|
| `prepare` | Branch → env resolution | — | 5 min |
| `test` | Language-specific tests | `prepare` | 10 min |
| `build-and-push` | Docker build, push env-scoped tags | `prepare`, `test` | 15 min |
| `deploy` | Tailscale → Ansible → target server | `prepare`, `build-and-push` | 10 min |

**Triggers**: `push` to `main`, `dev`, `test` + `workflow_dispatch`.

**Concurrency**:

```yaml
concurrency:
  group: deploy-${{ github.ref_name }}
  cancel-in-progress: false
```

Running deploy completes; queued pushes wait. Different branches run independently.

## Environment Resolution

The `prepare` job replaces 4 if/else blocks with a single `case` statement outputting everything downstream jobs need.

**Outputs**: `env_name`, `traefik_host`, `image_tag_prefix`.

| Branch | `env_name` | `image_tag_prefix` | `traefik_host` |
|--------|-----------|-------------------|---------------|
| `main` | `production` | `prod` | `<slug>.<base_domain_prod>` |
| `dev` | `dev` | `dev` | `<slug>.dev.<base_domain_dev>` |
| `test` | `test` | `test` | `<slug>.test.<base_domain_test>` |

`production` is used as the environment name because GitHub gives it a deploy shield icon. `prod` is used as tag prefix for brevity.

The traefik_host pattern intentionally changes from the previous `<slug>-<env>.<domain>` to `<slug>.<env>.<domain>` — the environment segment moves from a slug suffix to a subdomain level, which is cleaner when the base domain already implies the environment.

All downstream jobs reference `needs.prepare.outputs.*` — one source of truth, no re-derivation.

**Unsupported branches**: If `github.ref_name` doesn't match `main`, `dev`, or `test`, the `case` statement falls through to a default that prints an error and exits 1, failing the workflow immediately with a clear message.

**Example**:

```yaml
- name: Resolve environment
  id: env
  run: |
    case "${{ github.ref_name }}" in
      main)
        echo "env_name=production" >> $GITHUB_OUTPUT
        echo "image_tag_prefix=prod" >> $GITHUB_OUTPUT
        echo "traefik_host=<slug>.<base_domain_prod>" >> $GITHUB_OUTPUT
        ;;
      dev)
        echo "env_name=dev" >> $GITHUB_OUTPUT
        echo "image_tag_prefix=dev" >> $GITHUB_OUTPUT
        echo "traefik_host=<slug>.dev.<base_domain_dev>" >> $GITHUB_OUTPUT
        ;;
      test)
        echo "env_name=test" >> $GITHUB_OUTPUT
        echo "image_tag_prefix=test" >> $GITHUB_OUTPUT
        echo "traefik_host=<slug>.test.<base_domain_test>" >> $GITHUB_OUTPUT
        ;;
      *)
        echo "::error::Unsupported branch '${{ github.ref_name }}'"
        exit 1
        ;;
    esac
```

## Test Job

Each template gets a language-appropriate test job with dependency caching.

| Template | Setup action | Test command | Cache |
|----------|-------------|-------------|-------|
| Go | `actions/setup-go@v6` | `go test ./...` | Go module cache (built-in) |
| Node | `actions/setup-node@v6` + `pnpm/action-setup@v4` | `pnpm install --frozen-lockfile && pnpm test` | pnpm store (`pnpm/action-setup` built-in) |
| Python | `astral-sh/setup-uv@v7` | `uv pip install --system -r requirements.txt && pytest` | uv cache (`setup-uv` built-in) |

**Empty test suites**: Go exits 0 on "no test files". Node has a placeholder test script. Python uses `pytest || test $? -eq 5` to treat "no tests collected" (exit 5) as success.

**Why not test inside Docker build?** Coupling tests to the build makes failures harder to diagnose, caching is less effective, and a test failure still burns build time.

## Build & Image Tagging

**Docker actions upgraded**:

| Current | New |
|---------|-----|
| `docker/setup-buildx-action@v3` | `@v4` |
| `docker/login-action@v3` | `@v4` |
| (none) | `docker/metadata-action@v6` |
| `docker/build-push-action@v6` | `@v7` |

**Environment-scoped tags** replace the collision-prone scheme:

| Current | New (example: dev branch, SHA abc1234) |
|---------|----------------------------------------|
| `:latest` (overwritten by all branches) | `:dev-latest` |
| `:<sha>` | `:dev-abc1234` |

Tags use **short SHA** (7 characters) for readability. Tags and OCI labels are generated via `docker/metadata-action@v6`:

```yaml
- uses: docker/metadata-action@v6
  id: meta
  with:
    images: <registry>/<owner>/<slug>
    tags: |
      type=raw,value=${{ needs.prepare.outputs.image_tag_prefix }}-latest
      type=sha,prefix=${{ needs.prepare.outputs.image_tag_prefix }}-
```

The `type=sha` directive generates a short SHA tag by default (7 chars). The metadata action also generates standard OCI labels (`org.opencontainers.image.source`, `revision`, `created`) automatically, which aids image traceability.

GHA build cache (`cache-from: type=gha`, `cache-to: type=gha`) is retained.

## Deploy Job

### Per-env repo-level secrets

The deploy job SHALL NOT declare `environment:`. Secrets SHALL be repo-level with per-env names: `PROD_TAILSCALE_IP`, `DEV_TAILSCALE_IP`, `TEST_TAILSCALE_IP`, `PROD_SSH_KEY`, `DEV_SSH_KEY`, `TEST_SSH_KEY`. The workflow SHALL use case/if on `needs.prepare.outputs.env_name` to select the correct secret.

**Secret migration**:

| Old (environment-scoped) | New (per-env repo-level) |
|---|---|
| `SSH_KEY` (per environment) | `PROD_SSH_KEY`, `DEV_SSH_KEY`, `TEST_SSH_KEY` |
| IP/hostname (per environment) | `PROD_TAILSCALE_IP`, `DEV_TAILSCALE_IP`, `TEST_TAILSCALE_IP` |
| `DEPLOY_USER` (per environment, optional) | `DEPLOY_USER` (repo-level, optional) |
| `DEPLOY_REGISTRY_TOKEN` | stays repo-level (shared) |
| `TAILSCALE_OAUTH_*` | stays repo-level (shared) |

`DEPLOY_USER` defaults to `root` when not set — pragmatic for starter kit usage where most VPS providers give root by default and `bootstrap.yml` does not create a dedicated deploy user.

### Tailscale

The Tailscale authentication step is unchanged from the current workflow: `tailscale/github-action@v4` with `TAILSCALE_OAUTH_CLIENT_ID` and `TAILSCALE_OAUTH_SECRET` (repo-level secrets, shared across environments).

### Committed Playbook

The inline heredoc is replaced by a committed `.github/deploy.yml` Ansible playbook. Tasks:

1. Create deploy directory
2. Copy `docker-compose.yml`
3. Write `.env` (TRAEFIK_HOST, IMAGE_TAG)
4. Docker registry login
5. `docker compose pull && docker compose up -d`
6. Health check: `docker compose ps` verifies the container is `running`

The workflow step shrinks from 20+ lines to a single `ansible-playbook` call.

### Playbook Invocation Interface

The workflow invokes the committed playbook with:

```yaml
- name: Run deploy
  env:
    ANSIBLE_HOST_KEY_CHECKING: "False"
  run: |
    ansible_user="${{ secrets.DEPLOY_USER || 'root' }}"
    # server_ip selected via case/if on env_name
    printf '[all]\n%s\n' "$server_ip" > /tmp/inventory.yml
    ansible-playbook -i /tmp/inventory.yml .github/deploy.yml \
      -e ansible_user="$ansible_user" \
      -e ansible_ssh_private_key_file=~/.ssh/id_rsa \
      -e compose_src=$GITHUB_WORKSPACE/docker-compose.yml \
      -e deploy_registry_user=${{ github.repository_owner }} \
      -e deploy_registry_token=${{ secrets.DEPLOY_REGISTRY_TOKEN }} \
      -e traefik_host=${{ needs.prepare.outputs.traefik_host }} \
      -e image_tag=${{ needs.prepare.outputs.image_tag_prefix }}-latest
```

- **Inventory**: Dynamic, built from `PROD_TAILSCALE_IP`/`DEV_TAILSCALE_IP`/`TEST_TAILSCALE_IP` (selected via case/if) written to `/tmp/inventory.yml`
- **SSH key**: Written from `PROD_SSH_KEY`/`DEV_SSH_KEY`/`TEST_SSH_KEY` (selected via case/if) to `~/.ssh/id_rsa` in a prior step
- **Variables**: Passed as `-e` extra vars — `compose_src`, registry credentials, `traefik_host`, and `image_tag`
- **DEPLOY_USER**: Falls back to `root` when the secret is not set

### Ansible Installation via uv

Ansible is installed via `astral-sh/setup-uv@v7` + `uv tool install`, replacing the slower `actions/setup-python` + pip approach:

```yaml
- uses: astral-sh/setup-uv@v7
  with:
    enable-cache: true

- run: uv tool install ansible-core --with ansible
```

This is 10-100x faster than pip for package installation, and the uv cache is built-in. It also keeps the pipeline consistent — the Python test job already uses `setup-uv`.

### Post-deploy Health Check

The playbook includes a final task that waits briefly and checks `docker compose ps` for running status. Lightweight — no HTTP probing (the service may be internal-only). Just verifies the container didn't immediately crash.

## docker-compose.yml Changes

Image tag becomes configurable via environment variable:

```yaml
image: <registry>/<org>/<slug>:${IMAGE_TAG:-latest}
```

- Local development: `docker compose up` uses `:latest` (default)
- CI deploys: playbook injects `IMAGE_TAG=<env>-latest` into `.env`

## Node Template: pnpm Migration

The Node template migrates from npm to pnpm for faster dependency installation (3.4x cold, 10x+ cached).

| File | Change |
|------|--------|
| `package.json` | Add `"packageManager": "pnpm@10.x"` |
| `package-lock.json` | Remove, replace with `pnpm-lock.yaml` |
| `Dockerfile` | `corepack enable pnpm` → `pnpm install --frozen-lockfile --prod` |
| CI test job | `pnpm/action-setup@v4` + `pnpm install --frozen-lockfile` + `pnpm test` |
| README | Commands from `npm` to `pnpm` |

Dockerfile change:

```dockerfile
# Before
FROM node:24-alpine AS builder
COPY package.json package-lock.json* ./
RUN npm install --omit=dev

# After
FROM node:24-alpine AS builder
RUN corepack enable pnpm
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod
```

## What Changes Per Template

| Concern | Go | Node | Python |
|---------|-----|------|--------|
| Test setup | `setup-go@v6` | `setup-node@v6` + `pnpm/action-setup@v4` | `setup-uv@v7` |
| Test command | `go test ./...` | `pnpm test` | `pytest` |
| Package manager change | none | npm → pnpm | none |
| Dockerfile change | none | pnpm migration | none |
| CI workflow | shared structure, test job differs | shared structure, test job differs | shared structure, test job differs |
| deploy.yml | identical | identical | identical |
| docker-compose.yml | `IMAGE_TAG` env var | `IMAGE_TAG` env var | `IMAGE_TAG` env var |

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| GitHub Environments setup overhead | Teams must create 3 environments and move secrets post-scaffold | Document setup in generated README |
| Test job adds CI time | ~30-60s per run | Acceptable trade-off; dependency caching minimizes impact |
| Env-scoped tags break `latest` consumers | Automation pulling `:latest` stops getting updates | Document tag change; `docker-compose.yml` updated to new pattern |
| `cancel-in-progress: false` queues deploys | Second push waits for first to finish | At starter kit scale (1-10 people), this prevents races rather than causing delays |
| pnpm unfamiliarity | Node template users need to use pnpm locally | `corepack enable` is a one-liner; document in README |
| Docker action major version bumps | Potential breaking changes in v4/v7 | Pin to major version tags; changelogs show no breaking changes for our usage |
