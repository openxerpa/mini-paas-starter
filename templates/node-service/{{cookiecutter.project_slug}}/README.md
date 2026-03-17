# {{ cookiecutter.project_name }}

{{ cookiecutter.description }}

## Local development

```bash
# Enable pnpm (one-time)
corepack enable pnpm

# Install and run
pnpm install
docker compose up
```

## Deployment

Push to `main`, `dev`, or `test`; CI/CD builds and deploys automatically.

### Repo-level secrets

Add these secrets in **Settings → Secrets and variables → Actions**:

| Secret | Purpose |
|--------|---------|
| `PROD_TAILSCALE_IP` | Production server Tailscale IP (100.x.x.x) |
| `DEV_TAILSCALE_IP` | Dev server Tailscale IP |
| `TEST_TAILSCALE_IP` | Test server Tailscale IP |
| `PROD_SSH_KEY` | Production SSH private key |
| `DEV_SSH_KEY` | Dev SSH private key |
| `TEST_SSH_KEY` | Test SSH private key |
| `DEPLOY_USER` | (optional) SSH user; defaults to `root` when not set |

**Note:** These IP variables must be the target server's Tailscale IP (100.x.x.x). Do not use public IPs. SSH connects over Tailscale; servers typically do not expose public SSH ports.

Keep these repo-level (shared): `DEPLOY_REGISTRY_TOKEN`, `TAILSCALE_OAUTH_CLIENT_ID`, `TAILSCALE_OAUTH_SECRET`

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
