## Context

The deploy playbook always runs `docker login` before `docker compose pull`. For ghcr.io public packages, pull works without auth. The login step with empty token can fail or behave unexpectedly.

## Goals / Non-Goals

**Goals:**
- Skip docker login when DEPLOY_REGISTRY_TOKEN is empty
- Proceed to pull & up in both cases

**Non-Goals:**
- Supporting other auth methods (e.g. GITHUB_TOKEN on deploy target)

## Decisions

1. **Ansible `when` condition**: Add `when: deploy_registry_token | length > 0` to the docker login task. When token is empty, skip login.
2. **Pass empty string**: Workflow passes `-e deploy_registry_token=${{ secrets.DEPLOY_REGISTRY_TOKEN }}`; when unset, it's empty. Ansible receives empty string.
3. **Jinja2 filter**: `deploy_registry_token | default('') | length > 0` — handles undefined and empty.
