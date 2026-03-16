## Context

The Cookiecutter templates (go-service, node-service, python-service) each include a `.github/workflows/ci-cd.yml` that uses:
- `actions/checkout@v4` (current latest is v6)
- `tailscale/github-action@v2` (v4 is current; v2 uses deprecated `auth-key` parameter)
- `auth-key` for Tailscale (v4 renamed to `authkey`)

Tailscale v4 was rewritten in TypeScript and changed the input parameter from `auth-key` to `authkey`. Using the old parameter causes the deploy job to fail.

## Goals / Non-Goals

**Goals:**
- Update CI workflow to use supported action versions
- Fix Tailscale auth parameter for v4 compatibility
- Apply changes consistently across all three templates

**Non-Goals:**
- Migrating to Tailscale OAuth (auth keys remain supported)
- Changing other workflow steps or Ansible logic

## Decisions

1. **actions/checkout@v6**: v6 is the current major; no breaking changes for our usage (simple checkout).
2. **tailscale/github-action@v4**: v4 uses `authkey` (no hyphen). We keep auth-key-based auth; no OAuth migration.
3. **authkey parameter**: Replace `auth-key` with `authkey` in the `with:` block. Secret name `TAILSCALE_AUTHKEY` stays the same.

## Risks / Trade-offs

- **Risk**: Tailscale v4 may require `tags` parameter (per docs). → Mitigation: Check v4 README; if tags are required, add `tags: tag:ci` or similar.
- **Trade-off**: Existing projects generated before this fix will keep old workflow; they must update manually or re-scaffold.
