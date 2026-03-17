## Context

The main CI/CD workflow (`ci-cd.yml`) builds from source and deploys on push. With prod-tag-git-version, production deploys only on tag push. Teams need an emergency path: deploy an existing image tag (e.g. `v1.0.0` for rollback) without rebuild or tests. The deploy infrastructure (Tailscale, Ansible, `.github/deploy.yml`, environment-scoped secrets) already exists and can be reused.

## Goals / Non-Goals

**Goals:**
- Deploy any existing image tag to any environment (production, dev, test, dev-*) via GitHub UI
- No build, no test—deploy-only for speed
- Reuse existing deploy playbook and secrets
- Support rollback and emergency hotfix scenarios

**Non-Goals:**
- Tag picker dropdown (start with manual input; can add later)
- Deploy from a branch (use main ci-cd for that)
- Skipping tests in main ci-cd (separate concern)

## Decisions

### 1. Separate workflow vs. inputs on ci-cd.yml

**Chosen:** Separate `.github/workflows/emergency-deploy.yml`

**Rationale:** Emergency deploy has a different trigger (workflow_dispatch only), no prepare/test/build jobs, and different inputs. Merging into ci-cd would add conditional logic and complexity. A separate workflow keeps responsibilities clear and avoids accidental triggers.

**Alternative:** Add `workflow_dispatch` inputs to ci-cd for `image_tag` and `target_env`, with conditional job skipping. Rejected: too many conditionals, harder to reason about.

### 2. Input: `image_tag` (required string)

**Chosen:** User types the tag (e.g. `v1.0.0`, `dev-latest`, `prod-abc1234`)

**Rationale:** Simple, works for all tag formats. No API dependency. Typos are possible but acceptable for emergency use; user can retry.

**Alternative:** GitHub API to fetch tags and present dropdown. Rejected for v1: adds complexity; can add later if needed.

### 3. Input: `target_env` (required choice)

**Chosen:** `production | dev | test | dev-*` — maps to GitHub Environments, traefik_host, and deploy_dir. Developer environments use `dev-<username>` (e.g. `dev-alice`, `dev-bob`).

**Rationale:** Matches existing ci-cd for prod/dev/test; extends to per-developer environments. Production uses `environment: production` for protection rules.

### 4. Routing convention: `{app}.{env}.domain.com`

**Chosen:** Standard routing pattern:
- prod: `{app}.{domain}` → `<slug>.<base_domain_prod>`
- dev/test: `{app}.{env}.{domain}` → `<slug>.dev.<base_domain_dev>`, `<slug>.test.<base_domain_test>`
- dev-*: `{app}-{username}.{env}.{domain}` → `<slug>-alice.dev.<base_domain_dev>`

### 5. traefik_host and deploy_dir mapping

**Chosen:** Map `target_env` in a prepare step:

| target_env | traefik_host | deploy_dir |
|------------|--------------|------------|
| production | `<slug>.<base_domain_prod>` | `/opt/apps/<slug>` |
| dev | `<slug>.dev.<base_domain_dev>` | `/opt/apps/<slug>` |
| test | `<slug>.test.<base_domain_test>` | `/opt/apps/<slug>` |
| dev-alice | `<slug>-alice.dev.<base_domain_dev>` | `/opt/apps/<slug>-dev-alice` |
| dev-bob | `<slug>-bob.dev.<base_domain_dev>` | `/opt/apps/<slug>-dev-bob` |

For `dev-*`, extract username from target_env (e.g. `dev-alice` → `alice`) and use `<slug>-<username>` for traefik_host, `<slug>-<target_env>` for deploy_dir. Playbook receives `deploy_dir` as extra var when it differs from default.

### 6. compose_src and docker-compose.yml

**Chosen:** Checkout repo and use `$GITHUB_WORKSPACE/docker-compose.yml` as compose_src

**Rationale:** The deploy playbook copies docker-compose.yml to the target. We need the file from the repo; it doesn't change per tag. Checkout ensures we have it. If docker-compose structure changed (e.g. new env vars), we'd use the current main branch version—acceptable for emergency deploy.

## Risks / Trade-offs

| Risk | Mitigation |
|------|-------------|
| User enters wrong tag (typo, non-existent) | `docker compose pull` will fail; workflow fails with clear error |
| Deploying wrong env to prod | Use `environment: production`; require reviewers if configured |
| docker-compose.yml drift | Emergency deploy uses current main branch compose; if image expects different compose, may need manual fix |
| No concurrency | Emergency deploy doesn't use `concurrency`; could overlap with ci-cd deploy. Acceptable: both use same playbook; last deploy wins |

## Migration Plan

- Add workflow to templates; no migration for existing projects
- Document in README; teams can adopt when needed
- No rollout steps—new projects get it; existing projects can copy workflow if desired
