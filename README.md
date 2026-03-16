# Mini PaaS Starter

A monorepo providing infrastructure configs and Cookiecutter/Cruft project templates for a minimal PaaS targeting 1–10 person R&D teams. Get production-grade Docker + Traefik + Tailscale + Ansible with zero-config service discovery and scaffold new Go/Node.js/Python services in seconds.

**Target audience:** Small teams who want to deploy services quickly without Kubernetes or costly managed services.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) & Docker Compose
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html)
- [Tailscale](https://tailscale.com/download)
- [Cruft](https://cruft.github.io/cruft/) or [Cookiecutter](https://cookiecutter.readthedocs.io/)

## Quick start

### 1. Bootstrap a server

```bash
cd infra/ansible
ansible-playbook -i inventory/hosts.yml playbooks/bootstrap.yml -l production
```

Edit `inventory/hosts.yml` first: set `ansible_host` to your server's Tailscale IP.

### 2. Configure Traefik

```bash
cp infra/traefik/.env.example infra/traefik/.env
# Edit infra/traefik/.env and set TRAEFIK_DASHBOARD_HOST
```

### 3. Deploy Traefik

```bash
cd infra/ansible
ansible-playbook -i inventory/hosts.yml playbooks/traefik.yml -l production
```

### 4. (Optional) Join Tailscale on the server

```bash
ansible-playbook -i inventory/hosts.yml playbooks/tailscale.yml -l production -e "tailscale_auth_key=tskey-..."
```

### 5. Scaffold a new app

```bash
cruft create ./templates/go-service
# Or: ./templates/node-service, ./templates/python-service
```

## Directory overview

| Path | Description |
|------|-------------|
| `infra/traefik/` | Traefik v3 gateway (docker-compose, .env.example) |
| `infra/ansible/` | Playbooks: bootstrap, tailscale, traefik, deploy-app |
| `templates/go-service/` | Go service Cookiecutter template |
| `templates/node-service/` | Node.js service Cookiecutter template |
| `templates/python-service/` | Python service Cookiecutter template |
| `docs/` | Architecture and ops documentation |

## Deploying an app

From the scaffolded project:

```bash
ansible-playbook -i /path/to/mini-paas-starter/infra/ansible/inventory/hosts.yml \
  /path/to/mini-paas-starter/infra/ansible/playbooks/deploy-app.yml \
  -l production \
  -e "app_name=my-service compose_src=$(pwd)/docker-compose.yml gh_token=ghp_... deploy_registry_user=your-github-username"
```

Or push to `main` and let CI/CD handle it (requires GitHub secrets).

## Documentation

- [Architecture & traffic flows](docs/architecture.md)
- [Sample app: scaffold to deploy (CI/CD)](docs/sample-app-cicd-walkthrough.md)

## License

MIT
