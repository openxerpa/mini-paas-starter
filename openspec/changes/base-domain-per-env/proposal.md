## Why

Teams often use different base domains per environment (e.g. test: `a.com`, prod: `c.com`). The current single `base_domain` forces all envs to share one domain. Per-env base domains allow test/staging to use a separate domain from production.

## What Changes

- **Cookiecutter**: Replace single `base_domain` with `base_domain_dev`, `base_domain_test`, `base_domain_prod` in all three templates. Scaffold prompts for each.
- **CI/CD**: Env mapping uses the corresponding base domain (main → `base_domain_prod`, dev → `base_domain_dev`, test → `base_domain_test`). TRAEFIK_HOST = `{slug}.{base_domain_env}` for prod, `{slug}-{env}.{base_domain_env}` for dev/test.
- **Documentation**: Update `docs/sample-app-cicd-walkthrough.md` to describe per-env base domains.

## Capabilities

### New Capabilities

- _(none)_

### Modified Capabilities

- `template-go-service`: Replace `base_domain` with `base_domain_dev`, `base_domain_test`, `base_domain_prod`; CI uses per-env base domain
- `template-node-service`: Same as template-go-service
- `template-python-service`: Same as template-go-service
- `docs`: Update walkthrough for per-env base domains

## Impact

- **Templates**: `cookiecutter.json`, `.github/workflows/ci-cd.yml`, `.cruft.json` in each template
- **Docs**: `docs/sample-app-cicd-walkthrough.md`
- **BREAKING**: Existing scaffolds with single `base_domain` need to add per-env vars and update CI
