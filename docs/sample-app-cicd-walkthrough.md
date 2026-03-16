# Sample App: Scaffold to Deploy via CI/CD

This walkthrough shows how to scaffold a Go service and deploy it via CI/CD. **Prerequisite:** Infrastructure (server bootstrap, Traefik, Tailscale) and CI secrets are already configured by infra.

## Infra-managed setup

The following are typically configured by infra; app developers do not need to verify them:

- **Server bootstrap**: Docker, `traefik_webgateway` network, `/opt/apps/` — see [README quick start](../README.md#quick-start)
- **Traefik**: Gateway running on port 80 — see [Architecture traffic flows](architecture.md#traffic-flows)
- **Tailscale**: Server joined to mesh with Tailscale IP
- **CI secrets**: `TAILSCALE_OAUTH_CLIENT_ID`, `TAILSCALE_OAUTH_SECRET`, per-env `PROD_SERVER_IP`/`PROD_SSH_KEY`, `DEV_SERVER_IP`/`DEV_SSH_KEY`, `TEST_SERVER_IP`/`TEST_SSH_KEY`, `DEPLOY_REGISTRY_TOKEN` (optional for public images) — usually set at org/repo level

## Step 1: Scaffold the project

From the mini-paas-starter repo:

```bash
cruft create ./templates/go-service
```

When prompted:

- **project_name**: e.g. `Hello API`
- **description**: Short description of the service
- **github_org**: Your GitHub org or username
- **service_type**: `external` (reachable via Traefik) or `internal` (internal only)
- **service_port**: Default `3000` is fine
- **base_domain_dev**: Domain for dev (e.g. `a.com`)
- **base_domain_test**: Domain for test (e.g. `a.com`)
- **base_domain_prod**: Domain for prod (e.g. `c.com`). Different envs can use different domains (test: a.com, prod: c.com).
- **memory_limit**: Default `512M` is fine

CI derives TRAEFIK_HOST per branch: prod = `{slug}.{base_domain_prod}`, dev = `{slug}-dev.{base_domain_dev}`, test = `{slug}-test.{base_domain_test}`.

## Step 2: Confirm secrets

Infra usually configures these at org or repo level. Confirm your repo has:

- `TAILSCALE_OAUTH_CLIENT_ID` and `TAILSCALE_OAUTH_SECRET` — create an [OAuth client](https://tailscale.com/s/oauth-clients) with `auth_keys` scope and tag `tag:ci`
- Per-env: `PROD_SERVER_IP`, `PROD_SSH_KEY` (main); `DEV_SERVER_IP`, `DEV_SSH_KEY` (dev); `TEST_SERVER_IP`, `TEST_SSH_KEY` (test)
- `DEPLOY_USER` (optional; defaults to `deploy`)
- `DEPLOY_REGISTRY_TOKEN` (optional; required only for private images; GitHub PAT with `read:packages` for ghcr.io)

If you need project-specific vars (e.g. `DATABASE_URL`), add them in **Settings → Secrets and variables → Actions**.

## Step 3: Push to main

Create a new GitHub repo, add the remote, and push:

```bash
cd <your-scaffolded-project>
git remote add origin https://github.com/<org>/<repo>.git
git push -u origin main
```

CI/CD runs automatically: build-and-push → deploy. Push to `main` → prod domain; `dev` → dev domain; `test` → test domain.

## Step 4: Verify deployment

**External service** (`service_type: external`):

- Prod: `curl https://<slug>.<base_domain_prod>/` (e.g. `https://hello-api.c.com/`)
- Dev: `curl https://<slug>-dev.<base_domain_dev>/` (e.g. `https://hello-api-dev.a.com/`)
- Test: `curl https://<slug>-test.<base_domain_test>/` (e.g. `https://hello-api-test.a.com/`)

**Internal service** (`service_type: internal`):

- From a machine on the Tailscale network: `curl http://<slug>:3000/` (e.g. `http://hello-api:3000/`)

Expected response: `{"service":"<slug>","status":"ok"}`.

## Troubleshooting

| Issue | Check |
|-------|------|
| **Build fails** | Dockerfile, `go.mod`; verify image builds locally with `docker build .` |
| **Deploy fails** | Per-env server IP reachable via Tailscale; per-env SSH key works for `deploy` user; `DEPLOY_REGISTRY_TOKEN` has `read:packages` |
| **Service not reachable (external)** | DNS points to Traefik upstream (cloud LB); Traefik running; `.env` with `TRAEFIK_HOST` written to deploy dir |
| **Service not reachable (internal)** | Caller is on Tailscale network; use `http://<slug>:<port>` |
