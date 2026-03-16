## ADDED Requirements

### Requirement: Cookiecutter variables for Python template

The system SHALL provide `templates/python-service/cookiecutter.json` with `project_name`, `project_slug`, `description`, `github_org`, `service_type` (external/internal), `service_port`, `docker_registry`, `traefik_host`, and `memory_limit`.

#### Scenario: Cruft prompts for variables

- **WHEN** user runs `cruft create ./templates/python-service`
- **THEN** user is prompted for project_name, description, github_org, service_type, service_port, traefik_host, memory_limit

### Requirement: Python stdlib HTTP server

The system SHALL generate `src/main.py` with `http.server` stdlib server and single `/` handler returning `{"service": "<name>", "status": "ok"}`. The server SHALL read port from env (e.g. `PORT`).

#### Scenario: Health check response

- **WHEN** HTTP GET request is sent to `/` on the running service
- **THEN** response is JSON `{"service": "<project_slug>", "status": "ok"}`

### Requirement: Python requirements.txt

The system SHALL generate `requirements.txt` empty (stdlib only).

#### Scenario: No external dependencies

- **WHEN** user inspects `requirements.txt`
- **THEN** file is empty or contains only comments

### Requirement: Python Dockerfile

The system SHALL generate a single-stage Dockerfile using `python:3.13-slim` with non-root user (~50MB).

#### Scenario: Image builds successfully

- **WHEN** operator runs `docker build` in scaffolded project
- **THEN** image builds and runs the Python server

### Requirement: docker-compose with service type support

The system SHALL generate `docker-compose.yml` with `traefik_webgateway` external network, `deploy.resources.limits.memory` from `memory_limit`, and Jinja2 conditionals: external services get Traefik labels; internal services get `container_name` for DNS discovery, no labels, no ports.

#### Scenario: External service gets Traefik labels

- **WHEN** user selects `service_type: external` and scaffolds
- **THEN** generated docker-compose includes Traefik labels

#### Scenario: Internal service gets container name

- **WHEN** user selects `service_type: internal` and scaffolds
- **THEN** generated docker-compose has `container_name: {{ project_slug }}` and no Traefik labels

### Requirement: GitHub Actions CI/CD

The system SHALL generate `.github/workflows/ci-cd.yml` with `build-and-push` and `deploy` jobs matching the Go/Node template pattern (Tailscale, inline Ansible, required secrets).

#### Scenario: Push to main triggers deploy

- **WHEN** code is pushed to `main` branch
- **THEN** build-and-push runs, then deploy job runs
