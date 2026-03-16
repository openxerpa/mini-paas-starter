## Why

When images are public (e.g. ghcr.io packages from public repos), `docker pull` works without authentication. Requiring DEPLOY_REGISTRY_TOKEN forces users to create a PAT even when unnecessary. Making it optional simplifies setup for public-image deployments.

## What Changes

- **Conditional docker login**: Run `docker login` only when `DEPLOY_REGISTRY_TOKEN` is set. When empty, skip login and proceed to `docker compose pull` (works for public images).
- **DEPLOY_REGISTRY_TOKEN**: Optional secret. Required only for private registry images.

## Capabilities

### New Capabilities

- _(none)_

### Modified Capabilities

- `template-go-service`: Deploy playbook runs docker login only when registry token is provided
- `template-node-service`: Deploy playbook runs docker login only when registry token is provided
- `template-python-service`: Deploy playbook runs docker login only when registry token is provided

## Impact

- **Files**: `.github/workflows/ci-cd.yml` (inline Ansible playbook), `docs/sample-app-cicd-walkthrough.md`
- **Behavior**: Public images deploy without DEPLOY_REGISTRY_TOKEN; private images still require it
