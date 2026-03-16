## Why

The deploy step fails with "unknown shorthand flag: 'd' in -d" when running `docker compose pull && docker compose up -d`. The `ansible.builtin.command` module does not invoke a shell—it passes arguments literally. Shell operators like `&&` and flags like `-d` are passed as separate arguments to `docker`, causing incorrect parsing and failure.

## What Changes

- Replace `ansible.builtin.command` with `ansible.builtin.shell` for the "docker compose pull && docker compose up -d" task
- Apply the change to all three template CI workflows (go, node, python) and the infra playbooks
- Preserve `chdir` and other task parameters

## Capabilities

### New Capabilities

- None

### Modified Capabilities

- `template-ci-workflow`: Deploy playbook must use `ansible.builtin.shell` (not `command`) for commands that include shell operators (`&&`, `|`, etc.)

## Impact

- **Templates**: go-service, node-service, python-service CI workflows
- **Infra**: `infra/ansible/playbooks/deploy-app.yml`, `infra/ansible/playbooks/traefik.yml`
- **Behavior**: Deploy step succeeds; no functional change
