## ADDED Requirements

### Requirement: Cookiecutter variables for Node template

The system SHALL provide `templates/node-service/cookiecutter.json` with `project_name`, `project_slug`, `description`, `github_org`, `service_type` (external/internal), `service_port`, `docker_registry`, `traefik_host`, and `memory_limit`.

#### Scenario: Cruft prompts for variables

- **WHEN** user runs `cruft create ./templates/node-service`
- **THEN** user is prompted for project_name, description, github_org, service_type, service_port, traefik_host, memory_limit

### Requirement: Node stdlib HTTP server

The system SHALL generate `src/index.js` with `node:http` stdlib server and single `/` handler returning `{"service": "<name>", "status": "ok"}`. The server SHALL read port from env (e.g. `PORT`).

#### Scenario: Health check response

- **WHEN** HTTP GET request is sent to `/` on the running service
- **THEN** response is JSON `{"service": "<project_slug>", "status": "ok"}`

### Requirement: Node package.json

The system SHALL generate `package.json` with minimal config and `start` script.

#### Scenario: Service starts via npm start

- **WHEN** operator runs `npm start` in scaffolded project
- **THEN** HTTP server listens on configured port

### Requirement: Node Dockerfile

The system SHALL generate a two-stage Dockerfile: `node:22-alpine` builder (`npm ci --omit=dev`), `node:22-alpine` runtime with non-root user (~80MB).

#### Scenario: Image builds successfully

- **WHEN** operator runs `docker build` in scaffolded project
- **THEN** image builds and runs the Node server

### Requirement: docker-compose with service type support

The system SHALL generate `docker-compose.yml` with `traefik_webgateway` external network, `deploy.resources.limits.memory` from `memory_limit`, and Jinja2 conditionals: external services get Traefik labels; internal services get `container_name` for DNS discovery, no labels, no ports.

#### Scenario: External service gets Traefik labels

- **WHEN** user selects `service_type: external` and scaffolds
- **THEN** generated docker-compose includes Traefik labels

#### Scenario: Internal service gets container name

- **WHEN** user selects `service_type: internal` and scaffolds
- **THEN** generated docker-compose has `container_name: {{ project_slug }}` and no Traefik labels

### Requirement: GitHub Actions CI/CD

The system SHALL generate `.github/workflows/ci-cd.yml` with `build-and-push` and `deploy` jobs matching the Go template pattern (Tailscale, inline Ansible, required secrets).

#### Scenario: Push to main triggers deploy

- **WHEN** code is pushed to `main` branch
- **THEN** build-and-push runs, then deploy job runs
