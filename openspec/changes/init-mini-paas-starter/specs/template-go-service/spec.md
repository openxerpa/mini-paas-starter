## ADDED Requirements

### Requirement: Cookiecutter variables for Go template

The system SHALL provide `templates/go-service/cookiecutter.json` with `project_name`, `project_slug`, `description`, `github_org`, `service_type` (external/internal), `service_port`, `docker_registry`, `traefik_host`, and `memory_limit`.

#### Scenario: Cruft prompts for variables

- **WHEN** user runs `cruft create ./templates/go-service`
- **THEN** user is prompted for project_name, description, github_org, service_type, service_port, traefik_host, memory_limit

### Requirement: Go stdlib HTTP server

The system SHALL generate `cmd/server/main.go` with `net/http` stdlib server and single `/` handler returning `{"service": "<name>", "status": "ok"}`. The server SHALL read port from env (e.g. `PORT`).

#### Scenario: Health check response

- **WHEN** HTTP GET request is sent to `/` on the running service
- **THEN** response is JSON `{"service": "<project_slug>", "status": "ok"}`

### Requirement: Go Dockerfile

The system SHALL generate a two-stage Dockerfile: `golang:1.23-alpine` builder, `gcr.io/distroless/static-debian12` runtime (~10MB).

#### Scenario: Image builds successfully

- **WHEN** operator runs `docker build` in scaffolded project
- **THEN** image builds and runs the Go binary

### Requirement: docker-compose with service type support

The system SHALL generate `docker-compose.yml` with `traefik_webgateway` external network, `deploy.resources.limits.memory` from `memory_limit`, and Jinja2 conditionals: external services get Traefik labels; internal services get `container_name` for DNS discovery, no labels, no ports.

#### Scenario: External service gets Traefik labels

- **WHEN** user selects `service_type: external` and scaffolds
- **THEN** generated docker-compose includes Traefik labels (traefik.enable, router rule with traefik_host, load balancer server port)

#### Scenario: Internal service gets container name

- **WHEN** user selects `service_type: internal` and scaffolds
- **THEN** generated docker-compose has `container_name: {{ project_slug }}` and no Traefik labels; other services call via `http://<slug>:<port>`

### Requirement: GitHub Actions CI/CD

The system SHALL generate `.github/workflows/ci-cd.yml` with `build-and-push` job (checkout, ghcr.io login, build with layer cache, push latest + SHA) and `deploy` job (Tailscale setup, Ansible inline playbook for copy compose, docker login, pull & up). Required secrets: `TAILSCALE_AUTHKEY`, `GITHUB_TOKEN`, `DEPLOY_REGISTRY_TOKEN`, `ANSIBLE_SSH_PRIVATE_KEY`, `DEPLOY_HOST`, `DEPLOY_USER`.

#### Scenario: Push to main triggers deploy

- **WHEN** code is pushed to `main` branch
- **THEN** build-and-push runs, then deploy job runs with inline Ansible playbook
