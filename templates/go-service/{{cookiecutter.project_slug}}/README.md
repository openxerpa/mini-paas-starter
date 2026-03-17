# {{ cookiecutter.project_name }}

{{ cookiecutter.description }}

## Local development

```bash
docker compose up
```

## Deployment

Push to `main`, `dev`, or `test`; CI/CD builds and deploys automatically.

### GitHub Environments setup

1. Create environments: **production** (for `main`), **dev** (for `dev`), **test** (for `test`).
2. Add environment-scoped secrets to each:
   - `SSH_KEY` — SSH private key for the deploy server
   - `SERVER_IP` — Target server IP or hostname
   - `DEPLOY_USER` — (optional) SSH user; defaults to `root` when not set
3. Keep these repo-level (shared): `DEPLOY_REGISTRY_TOKEN`, `TAILSCALE_OAUTH_CLIENT_ID`, `TAILSCALE_OAUTH_SECRET`

### Emergency deploy

For rollback or deploying a specific image tag without rebuilding: **Actions** → **Emergency Deploy** → **Run workflow**.

| Input | Description |
|-------|-------------|
| `image_tag` | Docker image tag to deploy (e.g. `v1.0.0`, `dev-latest`, `prod-abc1234`) |
| `target_env` | `production`, `dev`, `test`, or `dev-<username>` (e.g. `dev-alice`) |

**Routing convention:** `{app}.{env}.domain.com` — e.g. `myapp.dev.example.com`, `myapp-alice.dev.example.com` for developer environments.

**Note:** The image must already exist in the registry.

## Environment variables

| Variable | Description |
|----------|-------------|
| `PORT` | HTTP server port (default: {{ cookiecutter.service_port }}) |

{% if cookiecutter.service_type == "internal" %}
**Note:** This is an internal service. The `base_domain_*` prompts are ignored; other services reach this via `http://{{ cookiecutter.project_slug }}:{{ cookiecutter.service_port }}`.
{% endif %}
