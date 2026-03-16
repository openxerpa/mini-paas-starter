## Why

When required deploy secrets (`DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_REGISTRY_TOKEN`, `ANSIBLE_SSH_PRIVATE_KEY`) are missing or empty, the CI deploy step fails with a cryptic error: "Could not resolve hostname ,: Name or service not known". The inventory becomes `,` when `DEPLOY_HOST` is empty, and Ansible tries to connect to an invalid host. Users need a clear, early failure that lists which secrets are missing.

## What Changes

- **Add deploy secrets validation step**: Before "Run deploy", run a validation step that checks required secrets are non-empty. If any are missing, fail with an explicit error listing the missing secrets.
- **Required secrets to validate**: `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_REGISTRY_TOKEN`, `ANSIBLE_SSH_PRIVATE_KEY` (and optionally `TS_OAUTH_CLIENT_ID`, `TS_OAUTH_SECRET` for Tailscale).

## Capabilities

### New Capabilities

- _(none)_

### Modified Capabilities

- `template-go-service`: CI deploy job SHALL validate required secrets before running Ansible
- `template-node-service`: CI deploy job SHALL validate required secrets before running Ansible
- `template-python-service`: CI deploy job SHALL validate required secrets before running Ansible

## Impact

- **Files**: `.github/workflows/ci-cd.yml` in each template (add one validation step before "Run deploy")
- **Behavior**: Deploy fails earlier with actionable error instead of cryptic Ansible/SSH failure
