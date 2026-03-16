## Why

App developers need a convention for multi-environment (dev/prod) domains without manually configuring `traefik_host` per env. Infra manages domains uniformly; apps should scaffold once with `base_domain` and let CI derive `TRAEFIK_HOST` per environment. Teams also need a walkthrough doc to run through scaffold → CI/CD deploy successfully.

## What Changes

- **Cookiecutter**: Replace `traefik_host` with `base_domain` in all three templates (Go, Node, Python). Scaffold prompts for `base_domain` only.
- **docker-compose**: Traefik router rule uses `${TRAEFIK_HOST}` (env var) instead of baked-in host. Deploy injects `.env` with `TRAEFIK_HOST` per environment.
- **CI/CD**: Add env mapping (main → prod, dev → dev), compute `TRAEFIK_HOST` from convention (`{slug}.{base_domain}` for prod, `{slug}-dev.{base_domain}` for dev). Deploy playbook writes `.env` before `docker compose up`. Clear comments so app can customize.
- **Documentation**: Add `docs/sample-app-cicd-walkthrough.md` — step-by-step from scaffold to deploy for infra-ready users, CI/CD path only, Go example, infra-managed configs briefly noted.

## Capabilities

### New Capabilities

- _(none)_

### Modified Capabilities

- `template-go-service`: Replace `traefik_host` with `base_domain`; docker-compose uses `${TRAEFIK_HOST}`; CI env mapping and `.env` injection
- `template-node-service`: Same as template-go-service
- `template-python-service`: Same as template-go-service
- `docs`: Add sample-app-cicd-walkthrough doc

## Impact

- **Templates**: `cookiecutter.json`, `docker-compose.yml`, `.github/workflows/ci-cd.yml` in each of go-service, node-service, python-service
- **Docs**: New `docs/sample-app-cicd-walkthrough.md`
- **Breaking**: Existing scaffolded projects using `traefik_host` will need to migrate (or re-scaffold). New scaffolds get `base_domain` instead.
