## Why

Tailscale GitHub Action v4 fails with "Please provide either an auth key, OAuth secret and tags, or federated identity client ID and audience with tags." The `authkey` input is deprecated; Tailscale recommends OAuth. The action now requires `tags` when using OAuth or federated identity, and auth-key-only usage may be failing validation.

## What Changes

- **Migrate Tailscale step to OAuth**: Replace `authkey` with `oauth-client-id`, `oauth-secret`, and `tags` (e.g. `tag:ci`). OAuth is the recommended, non-deprecated auth method.
- **Update required secrets**: `TAILSCALE_AUTHKEY` → `TS_OAUTH_CLIENT_ID`, `TS_OAUTH_SECRET`. Users must create an OAuth client at https://tailscale.com/s/oauth-clients with `auth_keys` scope and at least one tag.
- **Add `tags` parameter**: Required for OAuth; use `tag:ci` as default (users can customize via cookiecutter if needed later).

## Capabilities

### New Capabilities

- _(none)_

### Modified Capabilities

- `template-go-service`: CI Tailscale step uses OAuth instead of authkey; required secrets updated
- `template-node-service`: CI Tailscale step uses OAuth instead of authkey; required secrets updated
- `template-python-service`: CI Tailscale step uses OAuth instead of authkey; required secrets updated

## Impact

- **BREAKING**: Existing projects must migrate from `TAILSCALE_AUTHKEY` to `TS_OAUTH_CLIENT_ID` + `TS_OAUTH_SECRET` and create an OAuth client with tags.
- **Files**: `.github/workflows/ci-cd.yml` in each template; README/docs if we document the new secrets.
- **Docs**: Update README or add migration note for users with existing deployments.
