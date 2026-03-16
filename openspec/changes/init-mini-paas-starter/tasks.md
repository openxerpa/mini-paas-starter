## 1. Infra: Traefik

- [x] 1.1 Create `infra/traefik/docker-compose.yml` with Traefik v3, security hardening, web/dashboard entrypoints, Docker provider, and traefik_webgateway network
- [x] 1.2 Create `infra/traefik/.env.example` with TRAEFIK_DASHBOARD_HOST

## 2. Infra: Ansible

- [x] 2.1 Create `infra/ansible/ansible.cfg` with inventory, pipelining, host key check disabled
- [x] 2.2 Create `infra/ansible/inventory/hosts.yml` template with production/staging groups and Tailscale IPs
- [x] 2.3 Create `infra/ansible/inventory/group_vars/all.yml` with deploy_base_dir, docker_registry, traefik_deploy_dir, log settings
- [x] 2.4 Create `playbooks/bootstrap.yml` (Docker install, traefik_webgateway network, daemon.json, /opt/apps/)
- [x] 2.5 Create `playbooks/tailscale.yml` (install, auth key, verify status)
- [x] 2.6 Create `playbooks/traefik.yml` (copy compose + .env, docker compose up)
- [x] 2.7 Create `playbooks/deploy-app.yml` (app_name, compose_src, gh_token; copy, login, pull, up)

## 3. Template: Go Service

- [x] 3.1 Create `templates/go-service/cookiecutter.json` with shared variables and service_type
- [x] 3.2 Create `templates/go-service/{{cookiecutter.project_slug}}/cmd/server/main.go` stdlib HTTP server
- [x] 3.3 Create `templates/go-service/{{cookiecutter.project_slug}}/go.mod`
- [x] 3.4 Create `templates/go-service/{{cookiecutter.project_slug}}/Dockerfile` (two-stage: golang:1.23-alpine → distroless)
- [x] 3.5 Create `templates/go-service/{{cookiecutter.project_slug}}/docker-compose.yml` with Jinja2 external/internal conditionals
- [x] 3.6 Create `templates/go-service/{{cookiecutter.project_slug}}/.github/workflows/ci-cd.yml` (build-and-push, deploy)
- [x] 3.7 Create `templates/go-service/{{cookiecutter.project_slug}}/.env.example`, `.gitignore`, `README.md`, `.cruft.json`

## 4. Template: Node Service

- [x] 4.1 Create `templates/node-service/cookiecutter.json` with shared variables and service_type
- [x] 4.2 Create `templates/node-service/{{cookiecutter.project_slug}}/src/index.js` stdlib HTTP server
- [x] 4.3 Create `templates/node-service/{{cookiecutter.project_slug}}/package.json` with start script
- [x] 4.4 Create `templates/node-service/{{cookiecutter.project_slug}}/Dockerfile` (two-stage: node:22-alpine)
- [x] 4.5 Create `templates/node-service/{{cookiecutter.project_slug}}/docker-compose.yml` with Jinja2 external/internal conditionals
- [x] 4.6 Create `templates/node-service/{{cookiecutter.project_slug}}/.github/workflows/ci-cd.yml` (build-and-push, deploy)
- [x] 4.7 Create `templates/node-service/{{cookiecutter.project_slug}}/.env.example`, `.gitignore`, `README.md`, `.cruft.json`

## 5. Template: Python Service

- [x] 5.1 Create `templates/python-service/cookiecutter.json` with shared variables and service_type
- [x] 5.2 Create `templates/python-service/{{cookiecutter.project_slug}}/src/main.py` stdlib HTTP server
- [x] 5.3 Create `templates/python-service/{{cookiecutter.project_slug}}/requirements.txt` (empty)
- [x] 5.4 Create `templates/python-service/{{cookiecutter.project_slug}}/Dockerfile` (python:3.13-slim)
- [x] 5.5 Create `templates/python-service/{{cookiecutter.project_slug}}/docker-compose.yml` with Jinja2 external/internal conditionals
- [x] 5.6 Create `templates/python-service/{{cookiecutter.project_slug}}/.github/workflows/ci-cd.yml` (build-and-push, deploy)
- [x] 5.7 Create `templates/python-service/{{cookiecutter.project_slug}}/.env.example`, `.gitignore`, `README.md`, `.cruft.json`

## 6. Documentation

- [x] 6.1 Create root `README.md` with overview, prerequisites, quick start, directory table, link to architecture
- [x] 6.2 Create `docs/architecture.md` with vision, tech stack, traffic flows, setup reference, integration patterns, capacity planning
- [x] 6.3 Create root `.gitignore` and `LICENSE`
