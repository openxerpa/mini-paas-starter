## Why

The current CI/CD workflow in each service template (go, node, python) has six issues: duplicated branch-to-environment logic in four places, an inline Ansible heredoc that can't be linted or customized, no test stage (broken code deploys), no environment protection for production, image tag collision (all branches overwrite `:latest`), and slow pipelines (Ansible installed fresh every run). This refactor addresses all of these while keeping the pipeline simple and fast.

## What Changes

- **4-job linear pipeline**: `prepare` → `test` → `build-and-push` → `deploy` (replaces 2-job flow)
- **Single environment resolution**: One `prepare` job outputs `env_name`, `traefik_host`, `image_tag_prefix`; all downstream jobs consume these
- **Test job**: Language-specific tests (Go, Node, Python) with dependency caching before build
- **Environment-scoped image tags**: `:prod-latest`, `:dev-latest`, `:test-latest` instead of shared `:latest` — **BREAKING** for consumers expecting `:latest`
- **GitHub Environments**: Deploy job uses `environment: ${{ env_name }}` for env-scoped secrets and optional production reviewers — **BREAKING** secret migration (PROD_SSH_KEY → SSH_KEY per environment, etc.)
- **Committed Ansible playbook**: `.github/deploy.yml` replaces inline heredoc; playbook is lintable and customizable
- **Ansible via uv**: `uv tool install ansible-core` instead of pip for faster installs
- **docker-compose.yml**: Image tag configurable via `IMAGE_TAG` env var (`${IMAGE_TAG:-latest}`)
- **Node template**: Migrate from npm to pnpm — **BREAKING** for Node template users (package-lock.json → pnpm-lock.yaml, Dockerfile changes)

## Capabilities

### New Capabilities

- (none — all changes are modifications to existing CI workflow)

### Modified Capabilities

- `template-ci-workflow`: Add prepare job (branch → env resolution), test job (language-specific), env-scoped image tags, GitHub Environments (env-scoped secrets), committed `.github/deploy.yml` playbook, uv-based Ansible install; traefik_host pattern changes from `<slug>-<env>.<domain>` to `<slug>.<env>.<domain>`

## Impact

- **Templates**: `templates/go-service`, `templates/node-service`, `templates/python-service` — ci-cd.yml, docker-compose.yml, new .github/deploy.yml; Node template also gets pnpm migration (package.json, Dockerfile, lockfile)
- **Documentation**: Generated README must document GitHub Environments setup and secret migration
- **Dependencies**: Docker actions upgraded (buildx v4, login v4, metadata v6, build-push v7); Node template adds pnpm
