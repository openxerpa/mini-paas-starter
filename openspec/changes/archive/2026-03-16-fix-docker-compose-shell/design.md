## Context

The deploy playbook uses `ansible.builtin.command` for `docker compose pull && docker compose up -d`. The `command` module runs the executable directly without a shell—it does not interpret `&&`, pipes, or other shell syntax. Arguments are passed literally, causing `docker` to receive `&&`, `-d`, etc. as separate arguments and fail with "unknown shorthand flag: 'd' in -d".

## Goals / Non-Goals

**Goals:**
- Fix the deploy step so `docker compose pull && docker compose up -d` runs correctly
- Apply fix to templates and infra playbooks consistently

**Non-Goals:**
- Changing the command itself (pull then up -d)
- Splitting into two separate tasks (shell is simpler and preserves atomic behavior)

## Decisions

### Use `ansible.builtin.shell` for docker compose task

**Choice:** Replace `ansible.builtin.command` with `ansible.builtin.shell` for the pull/up task.

**Rationale:** The `shell` module runs the command through `/bin/sh`, so `&&` is interpreted correctly. The command executes as intended: pull first, then up -d only if pull succeeds.

**Alternatives considered:**
- Two separate `command` tasks: More verbose; need `changed_when` or `failed_when` to chain; rejected.
- `args: executable: /bin/bash` with command: Adds complexity; shell module is the standard approach.

### Apply to all five locations

**Choice:** Fix go-service, node-service, python-service CI templates; `deploy-app.yml`; `traefik.yml`.

**Rationale:** All use the same `docker compose pull && docker compose up -d` pattern with `command`; all will fail the same way.

## Risks / Trade-offs

- **[Shell injection]**: The command uses variables (`deploy_dir`). These are Ansible vars, not user input; low risk.
- **Minimal change**: Module swap only; `chdir` and other params work identically with shell.
