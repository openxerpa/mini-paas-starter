## Why

The deploy step in the generated CI workflows fails because `no_log` is passed as a parameter to `ansible.builtin.command`. In Ansible, `no_log` is a task-level directive, not a module parameter. The command module rejects it, causing the playbook to fail with "Unsupported parameters for (ansible.legacy.command) module: no_log".

## What Changes

- Fix YAML structure in the inline deploy playbook: move `no_log` from module parameters to task level
- Apply the same fix in `infra/ansible/playbooks/deploy-app.yml` (standalone playbook)
- Preserve intent: the docker login task output remains suppressed to avoid leaking credentials

## Capabilities

### New Capabilities

- None

### Modified Capabilities

- `template-ci-workflow`: Deploy playbook must use valid Ansible task structure (task-level directives like `no_log` at task level, not as module parameters)

## Impact

- **Templates**: go-service, node-service, python-service CI/CD workflows (inline playbook)
- **Infra**: `infra/ansible/playbooks/deploy-app.yml`
- **Behavior**: No functional change; deploy succeeds instead of failing
