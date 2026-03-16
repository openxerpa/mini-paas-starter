## Why

The CI/CD workflows in the Cookiecutter templates use outdated GitHub Action versions and an incorrect Tailscale parameter name. `actions/checkout@v4` and `tailscale/github-action@v2` should be updated for security and compatibility. Tailscale v4 changed the parameter from `auth-key` to `authkey`, causing deploy failures.

## What Changes

- **actions/checkout**: v4 → v6
- **tailscale/github-action**: v2 → v4
- **Tailscale auth parameter**: `auth-key` → `authkey` (v4 uses `authkey` without hyphen)

## Capabilities

### New Capabilities

- _(none)_

### Modified Capabilities

- `template-go-service`: CI workflow uses updated action versions and correct Tailscale v4 parameter
- `template-node-service`: CI workflow uses updated action versions and correct Tailscale v4 parameter
- `template-python-service`: CI workflow uses updated action versions and correct Tailscale v4 parameter

## Impact

- **Files**: `.github/workflows/ci-cd.yml` in each of `templates/go-service/`, `templates/node-service/`, `templates/python-service/` (inside the `{{cookiecutter.project_slug}}` scaffold)
- **Dependencies**: No new dependencies; action versions only
- **Breaking**: None; existing projects need to update their workflows manually if they were generated before this fix
