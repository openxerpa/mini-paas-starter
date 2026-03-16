## Why

Small R&D teams (1–10 people) need production-grade infrastructure to deploy services quickly, but existing PaaS options are either overkill (Kubernetes), costly (managed services), or require significant ops overhead. A minimal PaaS starter gives teams Docker + Traefik + Tailscale + Ansible with zero-config service discovery and one-command scaffolding via Cruft—getting from bare server to running services in minutes.

## What Changes

- **Infrastructure configs**: Traefik v3 gateway (docker-compose, .env.example), Ansible playbooks for bootstrap, Tailscale, Traefik deploy, and generic app deploy
- **Cookiecutter templates**: Go, Node.js, and Python service skeletons with stdlib-only apps, Dockerfile, docker-compose (external/internal service types), and GitHub Actions CI/CD
- **Documentation**: Root README with quick start, `docs/architecture.md` with traffic flows and ops guidelines
- **Project structure**: Flat monorepo with `infra/`, `templates/`, `docs/`

## Capabilities

### New Capabilities

- `infra-traefik`: Traefik v3 gateway with Docker provider, web/dashboard entrypoints, security hardening, and external `traefik_webgateway` network
- `infra-ansible`: Ansible playbooks (bootstrap, tailscale, traefik, deploy-app) with inventory and group_vars for Tailscale-based deployment
- `template-go-service`: Go service Cookiecutter template with stdlib HTTP server, two-stage Dockerfile, compose, and CI/CD
- `template-node-service`: Node.js service Cookiecutter template with stdlib HTTP server, two-stage Dockerfile, compose, and CI/CD
- `template-python-service`: Python service Cookiecutter template with stdlib HTTP server, Dockerfile, compose, and CI/CD
- `docs`: Root README and `docs/architecture.md` with quick start, directory overview, and architecture reference

### Modified Capabilities

- _(none)_

## Impact

- **New directories**: `infra/traefik/`, `infra/ansible/`, `templates/go-service/`, `templates/node-service/`, `templates/python-service/`, `docs/`
- **Dependencies**: Docker, Docker Compose, Ansible, Tailscale, Cruft/Cookiecutter
- **Conventions**: kebab-case for dirs/files, HTTP-only in Traefik (TLS upstream), stdlib-only app skeletons
