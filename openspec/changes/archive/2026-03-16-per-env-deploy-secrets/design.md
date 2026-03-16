## Context

Current workflow uses single DEPLOY_HOST, ANSIBLE_SSH_PRIVATE_KEY, TS_OAUTH_*. Users configure PROD_SERVER_IP, TEST_SERVER_IP, PROD_SSH_KEY, TEST_SSH_KEY, TAILSCALE_OAUTH_CLIENT_ID, TAILSCALE_OAUTH_SECRET.

## Goals / Non-Goals

**Goals:**
- Branch-based selection of deploy host and SSH key
- Support TAILSCALE_OAUTH_* naming
- DEPLOY_USER default "deploy" when unset

**Non-Goals:**
- Per-env DEPLOY_REGISTRY_TOKEN (keep single for now)

## Decisions

1. **Extend "Set TRAEFIK_HOST from branch" step** to also output `deploy_host` and `ssh_key` from env-specific secrets.
2. **Secret mapping**: main→PROD_*, dev→DEV_*, test→TEST_*. Use GitHub's `secrets.X` with dynamic key—not possible. Must use a run step to select: `echo "${{ secrets.PROD_SERVER_IP }}"` when branch is main, etc.
3. **DEPLOY_USER**: Use `${{ secrets.DEPLOY_USER }}` with fallback; GitHub Actions doesn't support default for secrets. Use a run step: `DEPLOY_USER="${DEPLOY_USER:-deploy}"` or output from env step.
4. **TAILSCALE_OAUTH_***: Direct rename in workflow.
