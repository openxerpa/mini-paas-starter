## Context

The CI deploy job uses `tailscale/github-action@v4` with `authkey: ${{ secrets.TAILSCALE_AUTHKEY }}`. Tailscale v4 deprecates `authkey` and recommends OAuth. The action fails with "Please provide either an auth key, OAuth secret and tags, or federated identity client ID and audience with tags." OAuth requires `oauth-client-id`, `oauth-secret`, and `tags`.

## Goals / Non-Goals

**Goals:**
- Fix the Tailscale setup step so deploy jobs succeed
- Remove deprecation warning by using OAuth
- Document new secrets for users

**Non-Goals:**
- Workload identity federation (OIDC) — more complex, OAuth is sufficient
- Tailnet Lock / pre-signed keys — out of scope for typical CI

## Decisions

1. **OAuth over authkey**: Tailscale recommends OAuth; authkey is deprecated. OAuth requires creating a client at https://tailscale.com/s/oauth-clients with `auth_keys` scope and at least one tag.
2. **Default tag `tag:ci`**: Standard tag for CI nodes. OAuth client must have this tag (or a tag that owns it) in its scope.
3. **Secrets: `TS_OAUTH_CLIENT_ID`, `TS_OAUTH_SECRET`**: Match Tailscale docs naming. Users replace `TAILSCALE_AUTHKEY` with these.
4. **Alternative considered**: Keep authkey and add `tags: tag:ci` — auth keys can have tags when created, but authkey is deprecated and the error suggests the action may no longer accept authkey-only; OAuth is the supported path.

## Risks / Trade-offs

- **[Risk] Breaking change for existing users** → Mitigation: README migration note; users must create OAuth client and update secrets
- **[Risk] OAuth client setup complexity** → Mitigation: Link to docs; one-time setup per tailnet
