## Context

Each service template (go, node, python) ships an identical `ci-cd.yml` with two jobs: `build-and-push` and `deploy`. Branch-to-environment logic is duplicated in four if/else blocks (SSH key, inventory IP, traefik host, deploy vars). The deploy step uses a 20+ line inline Ansible heredoc. There is no test stage, no environment protection for production, and all branches push `:latest` (overwriting each other). Ansible is installed via pip on every run with no caching.

## Goals / Non-Goals

**Goals:**
- Single source of truth for branch → environment mapping
- Committed, lintable Ansible playbook
- Test stage before build and deploy
- GitHub Environments for env-scoped secrets and optional production reviewers
- Environment-scoped image tags (no collision between branches)
- Fast pipeline via dependency caching and uv-based Ansible install
- Simplicity: one workflow file per template, linear job flow

**Non-Goals:**
- HTTP health probes (container `running` status is sufficient)
- Dedicated deploy user creation (bootstrap.yml does not create one; root default is pragmatic)
- Changing Tailscale auth flow
- Supporting branches other than main, dev, test

## Decisions

### 4-job linear pipeline
**Choice:** `prepare` → `test` → `build-and-push` → `deploy`  
**Rationale:** prepare centralizes env resolution; test catches broken code before build; build and deploy remain sequential.  
**Alternative:** Test inside Docker build — rejected because failures are harder to diagnose, caching less effective, and test failure still burns build time.

### Single case statement for env resolution
**Choice:** One `prepare` job with a shell `case` outputs `env_name`, `traefik_host`, `image_tag_prefix`; all downstream jobs use `needs.prepare.outputs.*`.  
**Rationale:** Eliminates four duplicated if/else blocks; one source of truth.  
**Alternative:** Keep per-job env logic — rejected for maintainability.

### traefik_host pattern: `<slug>.<env>.<domain>`
**Choice:** Change from `<slug>-<env>.<domain>` to `<slug>.dev.<base_domain_dev>` etc.  
**Rationale:** Environment as subdomain is cleaner when base domain already implies env.  
**Alternative:** Keep slug suffix — rejected for consistency with subdomain convention.

### Committed `.github/deploy.yml` playbook
**Choice:** Replace inline heredoc with committed playbook.  
**Rationale:** Lintable, customizable, version-controlled; workflow step shrinks to single `ansible-playbook` call.  
**Alternative:** Keep heredoc — rejected for maintainability.

### Ansible via uv
**Choice:** `uv tool install ansible-core --with ansible` instead of pip.  
**Rationale:** 10–100x faster; uv cache built-in; consistent with Python test job using setup-uv.  
**Alternative:** pip — rejected for speed.

### Environment-scoped image tags
**Choice:** `:prod-latest`, `:dev-latest`, `:test-latest` plus SHA tags (`:prod-abc1234`).  
**Rationale:** No collision; each branch deploys its own images.  
**Alternative:** Shared `:latest` — rejected (current problem).

### GitHub Environments
**Choice:** Deploy job declares `environment: ${{ env_name }}`; secrets move from repo-level (PROD_SSH_KEY, etc.) to env-scoped (SSH_KEY per environment).  
**Rationale:** Enables required reviewers for production, deployment history, status badges.  
**Alternative:** Keep repo-level secrets — rejected for production safety.

### Node template: pnpm migration
**Choice:** Migrate from npm to pnpm.  
**Rationale:** 3.4x faster cold install, 10x+ cached; `corepack enable` is one-liner.  
**Alternative:** Keep npm — rejected for CI speed.

### concurrency: cancel-in-progress: false
**Choice:** Same-branch deploys queue; different branches run independently.  
**Rationale:** Prevents deploy races; at starter kit scale (1–10 people) queuing is acceptable.  
**Alternative:** cancel-in-progress: true — rejected (could cancel mid-deploy).

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| GitHub Environments setup overhead | Document setup in generated README |
| Test job adds ~30–60s CI time | Dependency caching minimizes impact; acceptable trade-off |
| Env-scoped tags break `:latest` consumers | Document tag change; docker-compose uses IMAGE_TAG |
| pnpm unfamiliarity | Document `corepack enable` in README |
| Docker action major version bumps | Pin to major tags; changelogs show no breaking changes for our usage |

## Migration Plan

1. Implement changes in templates (ci-cd.yml, deploy.yml, docker-compose.yml).
2. Node template: add packageManager, replace lockfile, update Dockerfile and README.
3. Document GitHub Environments setup (create production, dev, test; move secrets).
4. No rollback strategy — templates are scaffolded at project creation; existing projects keep current workflow until they adopt the new template.

## Open Questions

- None; design is complete.
