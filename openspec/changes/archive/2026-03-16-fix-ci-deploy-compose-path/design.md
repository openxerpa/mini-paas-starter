## Context

The service templates (go, node, python) generate a GitHub Actions CI workflow that deploys via Ansible. The workflow writes an inline playbook to `/tmp/deploy.yml` and runs it. The playbook uses `ansible.builtin.copy` with `src: docker-compose.yml` (relative path). Ansible resolves relative paths from the playbook directory (`/tmp/`), but `docker-compose.yml` is in the repo checkout (`$GITHUB_WORKSPACE`). The file is never found.

## Goals / Non-Goals

**Goals:**
- Fix the deploy step so Ansible can locate and copy `docker-compose.yml`
- Apply the fix consistently across all three templates

**Non-Goals:**
- Changing the deploy flow (still inline playbook, same steps)
- Refactoring to use `infra/ansible/playbooks/deploy-app.yml` (that playbook uses `compose_src` correctly; the inline one does not)

## Decisions

### Use `compose_src` variable and pass workspace path

**Choice:** Add `compose_src` to the inline playbook vars, use `src: "{{ compose_src }}"` in the copy task, and pass `-e compose_src=$GITHUB_WORKSPACE/docker-compose.yml` from the workflow.

**Rationale:** `$GITHUB_WORKSPACE` is set by GitHub Actions to the repo root. The checkout places `docker-compose.yml` there. Passing an absolute path ensures Ansible finds the file regardless of playbook location.

**Alternatives considered:**
- **Write playbook next to checkout:** Write deploy.yml into `$GITHUB_WORKSPACE` so relative paths work. Rejected: clutters repo, playbook is ephemeral.
- **Use `lookup('env', 'GITHUB_WORKSPACE')` in playbook:** Would work but requires the var to be available. Passing via `-e` is explicit and matches `deploy-app.yml` pattern.

## Risks / Trade-offs

- **GITHUB_WORKSPACE availability:** Always set by GitHub Actions. No risk.
- **Path separator:** Unix paths; no Windows runner for deploy. Safe.
