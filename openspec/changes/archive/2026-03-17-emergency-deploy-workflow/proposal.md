## Why

When production uses tag-based deploys (prod-tag-git-version), teams need a way to rollback or deploy a specific version without rebuilding. The main CI/CD workflow always builds from source; for emergencies (rollback, hotfix deploy), teams want to select an existing image tag in GitHub and deploy it directly—no build, no tests.

## What Changes

- **New workflow**: `.github/workflows/emergency-deploy.yml` — `workflow_dispatch` only, deploy-only (no build, no test)
- **Inputs**: `image_tag` (required, e.g. `v1.0.0` or `dev-abc1234`), `target_env` (production | dev | test)
- **Flow**: Tailscale → Ansible deploy using existing image; reuses `.github/deploy.yml` and environment-scoped secrets
- **Use cases**: Rollback to older version, deploy specific tag without going through full CI

## Capabilities

### New Capabilities

- `template-emergency-deploy`: Workflow that deploys an existing image tag to a target environment on manual trigger, without build or test

### Modified Capabilities

- (none)

## Impact

- **Templates**: New `.github/workflows/emergency-deploy.yml` in go, node, python templates
- **Deploy flow**: Adds manual emergency path alongside push-triggered CI/CD
- **Documentation**: README documents when and how to use emergency deploy
