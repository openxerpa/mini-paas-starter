# Mini PaaS Starter — Design Spec

## Overview

A monorepo providing infrastructure configs and Cookiecutter/Cruft project templates for a minimal PaaS targeting 1–10 person R&D teams. Teams get production-grade Docker + Traefik + Tailscale + Ansible infrastructure with zero-config service discovery, and can scaffold new Go/Node.js/Python services in seconds via `cruft create`.

**Core tech stack:** Docker & Docker Compose, Traefik v3, Tailscale, Ansible, GitHub Actions.

## Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Repo structure | Flat monorepo (Approach A) | Simplest for small teams; trivial to split later |
| Template scope | App skeleton + Dockerfile + docker-compose + CI/CD | Enough to deploy; not so much that it's opinionated |
| Ansible scope | Full lifecycle (bootstrap, Traefik, Tailscale, deploy) | Team can go from bare server to running services |
| HTTPS/TLS | HTTP-only in Traefik | TLS terminated upstream by cloud LB or CDN |
| Service type | Single template per language, `service_type` toggle | DRY; avoids 6 near-duplicate templates |
| App dependencies | Stdlib-only skeletons | Teams add their own frameworks after scaffolding |

## Project Structure

```
mini-paas-starter/
├── infra/
│   ├── traefik/
│   │   ├── docker-compose.yml
│   │   └── .env.example
│   └── ansible/
│       ├── ansible.cfg
│       ├── playbooks/
│       │   ├── bootstrap.yml
│       │   ├── traefik.yml
│       │   ├── tailscale.yml
│       │   └── deploy-app.yml
│       └── inventory/
│           ├── hosts.yml
│           └── group_vars/
│               └── all.yml
├── templates/
│   ├── go-service/
│   │   ├── cookiecutter.json
│   │   └── {{cookiecutter.project_slug}}/
│   ├── node-service/
│   │   ├── cookiecutter.json
│   │   └── {{cookiecutter.project_slug}}/
│   └── python-service/
│       ├── cookiecutter.json
│       └── {{cookiecutter.project_slug}}/
├── docs/
│   └── architecture.md
├── .gitignore
├── LICENSE
└── README.md
```

**Naming conventions:**
- Directories: `kebab-case`
- YAML files: `kebab-case.yml`
- Ansible playbooks: named by what they do, not when they run
- Cookiecutter template dirs: `{{cookiecutter.project_slug}}/` per convention

## Infra: Traefik Gateway

File: `infra/traefik/docker-compose.yml`

- Image: `traefik:v3`, restart `unless-stopped`
- Security hardening: `no-new-privileges:true`, `cap_drop: ALL`, `cap_add: NET_BIND_SERVICE`
- Docker provider: `exposedbydefault=false`, `network=traefik_webgateway`
- Entrypoints: `web` on port 80, `dashboard` on port 8080
- Docker socket mounted read-only (`/var/run/docker.sock:/var/run/docker.sock:ro`)
- Dashboard exposed via Traefik labels on the `dashboard` entrypoint
- External network `traefik_webgateway` (created by bootstrap playbook)
- Dashboard host read from `${TRAEFIK_DASHBOARD_HOST}` env var
- Dashboard has no built-in auth — access is restricted by cloud firewall rules limiting port 8080 to internal/Tailscale IPs only

File: `infra/traefik/.env.example`

```
# Hostname for the Traefik dashboard (routed via Traefik labels)
TRAEFIK_DASHBOARD_HOST=traefik.yourdomain.com
```

This is the only env var. The rest of the Traefik config is static in compose `command` args.
- All config via compose `command` args (no separate static config file — config is minimal enough)

## Infra: Ansible Playbooks

All playbooks are idempotent — safe to re-run without side effects. Ansible modules like `file`, `copy`, and `template` are inherently idempotent; `command` tasks use `creates` or conditional checks where needed.

### `playbooks/bootstrap.yml` — Server initialization

Run once on a fresh server:
- Install Docker Engine + Docker Compose plugin via official Docker apt repo
- Create `traefik_webgateway` external Docker network
- Configure Docker daemon log rotation in `/etc/docker/daemon.json` (`max-size: 50m`, `max-file: 3`)
- Create base deploy directory `/opt/apps/`
- Restart Docker daemon

### `playbooks/tailscale.yml` — Join Tailscale mesh

- Install Tailscale via official package repo
- Authenticate with auth key passed as `--extra-vars "tailscale_auth_key=tskey-..."` (never stored in files)
- Enable IP forwarding if needed
- Verify connectivity

### `playbooks/traefik.yml` — Deploy/update Traefik

- Ensure `/opt/traefik/` directory exists
- Copy `infra/traefik/docker-compose.yml` and `.env` to server
- Run `docker compose pull && docker compose up -d`

### `playbooks/deploy-app.yml` — Generic app rolling update

Parameterized, reusable across all services:
- Takes `app_name` via `--extra-vars`
- Ensures `/opt/apps/{{ app_name }}/` exists
- Copies the app's `docker-compose.yml` to server
- Logs in to container registry (`gh_token` passed as extra var — a GitHub PAT with `read:packages` scope, since `GITHUB_TOKEN` from Actions cannot authenticate across repos)
- Runs `docker compose pull && docker compose up -d`

### `inventory/hosts.yml`

Groups by environment, uses Tailscale IPs:

```yaml
all:
  children:
    production:
      hosts:
        server-1:
          ansible_host: 100.x.x.x  # Tailscale IP
    staging:
      hosts:
        server-2:
          ansible_host: 100.x.x.x
  vars:
    ansible_user: deploy
    ansible_python_interpreter: /usr/bin/python3
```

### `inventory/group_vars/all.yml`

Shared variables used across playbooks:

```yaml
deploy_base_dir: /opt/apps
docker_registry: ghcr.io
docker_log_max_size: 50m
docker_log_max_file: "3"
traefik_deploy_dir: /opt/traefik
```

### `ansible.cfg`

- Default inventory: `inventory/hosts.yml`
- SSH pipelining enabled
- Host key checking disabled (Tailscale IPs are trusted)

## Templates: Cookiecutter Variables

All three templates share the same `cookiecutter.json`:

```json
{
  "project_name": "My Service",
  "project_slug": "{{ cookiecutter.project_name|lower|replace(' ', '-') }}",
  "description": "A short description of the service",
  "github_org": "your-org",
  "service_type": ["external", "internal"],
  "service_port": "3000",
  "docker_registry": "ghcr.io",
  "traefik_host": "{{ cookiecutter.project_slug }}.yourdomain.com",
  "memory_limit": "512M"
}
```

- `service_type`: choice variable — Cruft prompts user to pick external or internal
- `traefik_host`: Cookiecutter always prompts for this (no conditional prompting in cookiecutter.json). The default value is reasonable, and the value is simply ignored in the template when `service_type == "internal"`. The generated README notes this.

## Templates: Generated Project Structure

Each scaffolded project contains:

```
{{ cookiecutter.project_slug }}/
├── .github/
│   └── workflows/
│       └── ci-cd.yml
├── src/                    # or cmd/ for Go
│   └── ...
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── .gitignore
├── .cruft.json
└── README.md
```

### docker-compose.yml

Uses Jinja2 conditionals in the template. Both modes declare the `traefik_webgateway` network as external:

```yaml
networks:
  webgateway:
    external: true
    name: traefik_webgateway
```

- `service_type == "external"`: includes Traefik labels (`traefik.enable=true`, router rule with `traefik_host`, load balancer server port), service attached to `webgateway` network
- `service_type == "internal"`: no labels, no ports, just `webgateway` network with container name for DNS discovery

### Language-Specific App Skeletons

**Go (`templates/go-service`):**
- `cmd/server/main.go`: `net/http` stdlib server, single `/` handler returning `{"service": "<name>", "status": "ok"}`
- `go.mod`: module `github.com/{{ cookiecutter.github_org }}/{{ cookiecutter.project_slug }}`
- Dockerfile: two-stage — `golang:1.23-alpine` builder, `gcr.io/distroless/static-debian12` runtime (~10MB)

**Node.js (`templates/node-service`):**
- `src/index.js`: `node:http` stdlib server, same JSON response
- `package.json`: minimal with `start` script
- Dockerfile: two-stage — `node:22-alpine` builder (`npm ci --omit=dev`), `node:22-alpine` runtime with non-root user (~80MB)

**Python (`templates/python-service`):**
- `src/main.py`: `http.server` stdlib server, same JSON response
- `requirements.txt`: empty (stdlib only)
- Dockerfile: single-stage `python:3.13-slim`, non-root user (~50MB)

All skeletons are stdlib-only. Teams add their own frameworks after scaffolding.

## Templates: GitHub Actions CI/CD

File: `.github/workflows/ci-cd.yml` (generated inside each scaffolded project)

**Triggers:** `push` to `main`, `workflow_dispatch`

**Job 1: `build-and-push`**
- Checkout code
- Login to `{{ cookiecutter.docker_registry }}` via `GITHUB_TOKEN`
- Build Docker image tagged `latest` + short git SHA
- Push both tags
- Docker layer caching via `docker/build-push-action` with GitHub Actions cache backend

**Job 2: `deploy`** (depends on build-and-push)
- Set up Tailscale using `tailscale/github-action` with `TAILSCALE_AUTHKEY` secret
- Install Ansible via pip
- Write SSH private key from `ANSIBLE_SSH_PRIVATE_KEY` secret to a temp file
- Write an inline inventory from `DEPLOY_HOST` secret (Tailscale IP) — this keeps the workflow self-contained without needing the infra repo
- Run an inline deploy playbook embedded in the workflow YAML (a simplified copy of `deploy-app.yml` that pulls and restarts the service's own compose stack)
- The inline playbook is a stripped-down version of `deploy-app.yml` with hardcoded values instead of `group_vars` references: it uses `DEPLOY_HOST`/`DEPLOY_USER` secrets as the inventory, hardcodes the app name from the cookiecutter slug, and performs the same steps — ensure dir, copy compose file, registry login, `docker compose pull && docker compose up -d`

**Required GitHub secrets:**
- `TAILSCALE_AUTHKEY`: ephemeral key for CI runner to join Tailscale network
- `GITHUB_TOKEN`: auto-provided, used for ghcr.io login on the build job
- `DEPLOY_REGISTRY_TOKEN`: GitHub PAT with `read:packages` scope for the deploy target to pull images
- `ANSIBLE_SSH_PRIVATE_KEY`: SSH key for Ansible to connect to servers via Tailscale
- `DEPLOY_HOST`: Tailscale IP of the target server
- `DEPLOY_USER`: SSH user on the target server (default: `deploy`)

## Documentation

### `README.md` (root)
- Project overview and target audience
- Prerequisites: Docker, Ansible, Tailscale, Cruft/Cookiecutter
- Quick start workflows:
  1. Bootstrap a server: `ansible-playbook infra/ansible/playbooks/bootstrap.yml`
  2. Deploy Traefik: `ansible-playbook infra/ansible/playbooks/traefik.yml`
  3. Scaffold a new app: `cruft create ./templates/go-service`
- Directory overview table
- Link to `docs/architecture.md`

### `docs/architecture.md`
English version of the original architecture document, covering:
- Vision and core advantages (zero-agent, zero-trust, zero-config routing)
- Tech stack overview
- Traffic flows (CI/CD, north-south, east-west) in text/ASCII
- Infrastructure setup reference
- Application integration patterns
- Capacity planning and ops guidelines

### Generated project `README.md`
Each scaffolded project gets a README with:
- Service description (from `cookiecutter.description`)
- Local development: `docker compose up`
- Deployment: push to main, CI/CD handles the rest
- Environment variables reference
