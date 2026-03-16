## Context

The deploy playbook (inline in CI workflows and standalone in `infra/ansible/playbooks/deploy-app.yml`) uses `ansible.builtin.command` for the docker login task. The task includes `no_log: true` to suppress output and avoid leaking credentials. However, `no_log` is indented as a child of the module, so Ansible treats it as a module parameter. The `ansible.builtin.command` module does not support `no_log`; it is a task-level directive.

## Goals / Non-Goals

**Goals:**
- Fix the Ansible playbook so the deploy step succeeds
- Preserve credential suppression (no_log behavior)
- Apply fix consistently across templates and infra playbook

**Non-Goals:**
- Changing deploy logic or adding new features
- Migrating to a different module (e.g., `community.docker.docker_login`)

## Decisions

### Move `no_log` to task level

**Choice:** Place `no_log` as a sibling of the module name, not nested under it.

**Rationale:** In Ansible, task-level directives (`no_log`, `when`, `register`, etc.) must be at the same indentation level as the module. Nested under the module, they are passed as module parameters and cause "Unsupported parameters" errors.

**Correct structure:**
```yaml
- ansible.builtin.command:
    cmd: docker login ...
  no_log: true
  when: ...
```

**Alternatives considered:**
- Remove `no_log`: Would leak credentials in logs; rejected.
- Use `block` with `no_log`: Adds complexity; unnecessary when task-level placement works.

### Apply to all four locations

**Choice:** Fix go-service, node-service, python-service CI templates and `infra/ansible/playbooks/deploy-app.yml`.

**Rationale:** All four use the same incorrect pattern; fixing one and missing others would leave partial failures.

## Risks / Trade-offs

- **Minimal risk:** YAML structure change only; behavior unchanged.
- **Verification:** Run `ansible-playbook` (or CI) to confirm deploy succeeds.
