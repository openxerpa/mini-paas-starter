## Why

Users often configure per-environment secrets (PROD_SERVER_IP, TEST_SERVER_IP, PROD_SSH_KEY, TEST_SSH_KEY) and Tailscale OAuth as TAILSCALE_OAUTH_CLIENT_ID / TAILSCALE_OAUTH_SECRET. The template currently expects single-env names (DEPLOY_HOST, ANSIBLE_SSH_PRIVATE_KEY, TS_OAUTH_*). Aligning the template with common naming reduces secret duplication and configuration errors.

## What Changes

- **Tailscale secrets**: `TS_OAUTH_CLIENT_ID` → `TAILSCALE_OAUTH_CLIENT_ID`, `TS_OAUTH_SECRET` → `TAILSCALE_OAUTH_SECRET`
- **Per-env deploy host**: main → `PROD_SERVER_IP`, dev → `DEV_SERVER_IP`, test → `TEST_SERVER_IP`
- **Per-env SSH key**: main → `PROD_SSH_KEY`, dev → `DEV_SSH_KEY`, test → `TEST_SSH_KEY`
- **DEPLOY_USER**: Optional; default `deploy` when unset
- **DEPLOY_REGISTRY_TOKEN**: Keep as single secret (shared across envs) or add per-env later

## Capabilities

### New Capabilities

- _(none)_

### Modified Capabilities

- `template-go-service`: CI uses per-env secrets and TAILSCALE_OAUTH_* naming
- `template-node-service`: CI uses per-env secrets and TAILSCALE_OAUTH_* naming
- `template-python-service`: CI uses per-env secrets and TAILSCALE_OAUTH_* naming

## Impact

- **BREAKING**: Existing projects using DEPLOY_HOST, ANSIBLE_SSH_PRIVATE_KEY, TS_OAUTH_* must migrate to new secret names
- **Files**: `.github/workflows/ci-cd.yml`, `docs/sample-app-cicd-walkthrough.md`
