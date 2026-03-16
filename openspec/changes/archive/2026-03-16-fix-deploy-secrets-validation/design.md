## Context

The deploy job runs Ansible with `-e ansible_user=${{ secrets.DEPLOY_USER }}` etc. When secrets are unset, they expand to empty strings. The inventory `echo "${{ secrets.DEPLOY_HOST }},"` becomes `,` when DEPLOY_HOST is empty, causing "Could not resolve hostname ,".

## Goals / Non-Goals

**Goals:**
- Fail fast before Ansible with a clear error listing missing secrets
- Validate: DEPLOY_HOST, DEPLOY_USER, DEPLOY_REGISTRY_TOKEN, ANSIBLE_SSH_PRIVATE_KEY, TS_OAUTH_CLIENT_ID, TS_OAUTH_SECRET

**Non-Goals:**
- Validating secret format or connectivity; only presence check

## Decisions

1. **Single validation step** before "Run deploy": One step that checks all required secrets. Simpler than per-secret checks.
2. **Bash `[ -z "$var" ]`**: Standard way to detect empty in Actions; secrets expand to empty string when unset.
3. **Error format**: `echo "::error::Missing required secrets: DEPLOY_HOST DEPLOY_USER ..."` so GitHub UI shows the error clearly.
4. **Include Tailscale secrets**: TS_OAUTH_CLIENT_ID, TS_OAUTH_SECRET fail earlier (Tailscale step) but validating them in the same step keeps the list complete and consistent.

## Risks / Trade-offs

- **[Risk] Secret names in error** → Mitigation: Only names, not values; acceptable for debugging
