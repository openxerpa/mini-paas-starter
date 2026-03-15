---
name: Init Mini PaaS Starter
overview: Initialize a mini-PaaS starter project based on the architecture doc, containing infrastructure configs (Traefik, Ansible, GitHub Actions) and Cruft/Cookiecutter templates for Go, Node.js, and Python services.
todos:
  - id: infra-traefik
    content: Create infra/traefik/ with docker-compose.yml and .env.example for Traefik v3 gateway
    status: pending
  - id: infra-ansible
    content: Create infra/ansible/ with ansible.cfg, inventory template, deploy.yml, and setup-server.yml playbooks
    status: pending
  - id: infra-docker-scripts
    content: Create infra/docker/daemon.json and infra/scripts/bootstrap-server.sh
    status: pending
  - id: template-go
    content: Create templates/go-service/ Cookiecutter template with Go app, Dockerfile, compose, CI/CD
    status: pending
  - id: template-node
    content: Create templates/node-service/ Cookiecutter template with Node.js/TS app, Dockerfile, compose, CI/CD
    status: pending
  - id: template-python
    content: Create templates/python-service/ Cookiecutter template with Python/FastAPI app, Dockerfile, compose, CI/CD
    status: pending
  - id: root-files
    content: Create root README.md, .gitignore, and .github/workflows/template-lint.yml
    status: pending
  - id: git-init
    content: Initialize git repo and make initial commit
    status: pending
isProject: false
---

# Mini PaaS Starter Project Initialization

## Target Directory Structure

```
mini-paas-starter/
├── README.md
├── infra/
│   ├── traefik/
│   │   └── docker-compose.yml
│   ├── ansible/
│   │   ├── ansible.cfg
│   │   ├── inventory/
│   │   │   └── hosts.yml
│   │   └── playbooks/
│   │       ├── deploy.yml
│   │       └── setup-server.yml
│   ├── docker/
│   │   └── daemon.json
│   └── scripts/
│       └── bootstrap-server.sh
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
└── .github/
    └── workflows/
        └── template-lint.yml
```

---

## Part 1: Infrastructure (`infra/`)

### 1.1 Traefik Gateway -- `infra/traefik/docker-compose.yml`

- Traefik v3 with security hardening (no-new-privileges, cap_drop ALL, cap_add NET_BIND_SERVICE)
- Read-only Docker socket mount
- Dashboard on port 8080 with host-based routing
- External network `traefik_webgateway`
- Parameterized domain via `.env` file (with `.env.example`)

### 1.2 Ansible Deployment -- `infra/ansible/`

- `ansible.cfg` -- disable host key checking for CI, set defaults
- `inventory/hosts.yml` -- template inventory with Tailscale IPs
- `playbooks/deploy.yml` -- idempotent app deployment playbook per the arch doc (ensure dir, copy compose, docker login, pull & up)
- `playbooks/setup-server.yml` -- one-time server bootstrap (install Docker, create `traefik_webgateway` network, configure daemon.json)

### 1.3 Docker Daemon Config -- `infra/docker/daemon.json`

- JSON log driver with max-size 50MB, max-file 3 (per arch doc Section 7)

### 1.4 Bootstrap Script -- `infra/scripts/bootstrap-server.sh`

- Shell script to install Docker, Tailscale, create the shared network, and apply daemon.json

---

## Part 2: Cruft Templates (`templates/`)

Each template is a standalone Cookiecutter repo that Cruft can use. Common `cookiecutter.json` variables:

```json
{
  "project_name": "My Service",
  "project_slug": "{{ cookiecutter.project_name | lower | replace(' ', '-') }}",
  "description": "A short description",
  "org_name": "your-org",
  "service_type": ["public", "internal"],
  "domain": "api.yourdomain.com",
  "container_port": "3000",
  "memory_limit": "512M"
}
```

### 2.1 Go Service Template -- `templates/go-service/`

Inside `{{cookiecutter.project_slug}}/`:

- `main.go` -- minimal HTTP server (net/http)
- `go.mod`
- `Dockerfile` -- multi-stage build (golang:1.23-alpine builder -> scratch/alpine runtime)
- `docker-compose.yml` -- conditional Traefik labels via Jinja (public vs internal)
- `.github/workflows/ci.yml` -- build, test, push to GHCR
- `.github/workflows/deploy.yml` -- trigger Ansible deploy via Tailscale
- `.env.example`, `README.md`, `.gitignore`, `.dockerignore`

### 2.2 Node.js Service Template -- `templates/node-service/`

Inside `{{cookiecutter.project_slug}}/`:

- `src/index.ts` -- minimal Express/Fastify server
- `package.json`, `tsconfig.json`
- `Dockerfile` -- multi-stage build (node:22-alpine)
- `docker-compose.yml` -- same Traefik label pattern
- `.github/workflows/ci.yml` and `deploy.yml`
- `.env.example`, `README.md`, `.gitignore`, `.dockerignore`

### 2.3 Python Service Template -- `templates/python-service/`

Inside `{{cookiecutter.project_slug}}/`:

- `app/main.py` -- minimal FastAPI server
- `requirements.txt`
- `Dockerfile` -- multi-stage build (python:3.12-slim)
- `docker-compose.yml` -- same Traefik label pattern
- `.github/workflows/ci.yml` and `deploy.yml`
- `.env.example`, `README.md`, `.gitignore`, `.dockerignore`

---

## Part 3: Root Files

### 3.1 `README.md`

- Project overview, architecture diagram (Mermaid), quickstart guide
- How to use Cruft to scaffold a new service
- Infrastructure setup instructions

### 3.2 `.github/workflows/template-lint.yml`

- CI to validate cookiecutter templates render correctly

### 3.3 `.gitignore`

- Standard ignores for the mono-repo (*.env, .DS_Store, etc.)

---

## Key Design Decisions

- **Cookiecutter Jinja2 conditionals** in `docker-compose.yml` templates handle public vs internal service type -- public services get Traefik labels, internal services get none
- **GitHub Actions workflows** in each template use GHCR as the container registry (matching the arch doc's `ghcr.io/your-org/` pattern)
- **Ansible playbooks** use the Tailscale network for zero-trust SSH access (no public SSH ports)
- **All names in English**, kebab-case for directories/files, following Docker and Ansible community conventions
