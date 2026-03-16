## MODIFIED Requirements

### Requirement: Cookiecutter variables for Node template

The system SHALL provide `templates/node-service/cookiecutter.json` with `project_name`, `project_slug`, `description`, `github_org`, `service_type` (external/internal), `service_port`, `docker_registry`, `base_domain`, and `memory_limit`. The system SHALL NOT include `traefik_host`.

#### Scenario: Cruft prompts for variables

- **WHEN** user runs `cruft create ./templates/node-service`
- **THEN** user is prompted for project_name, description, github_org, service_type, service_port, base_domain, memory_limit

### Requirement: docker-compose with service type support

The system SHALL generate `docker-compose.yml` with `traefik_webgateway` external network, `deploy.resources.limits.memory` from `memory_limit`, and Jinja2 conditionals: external services get Traefik labels with router rule `Host(\`${TRAEFIK_HOST}\`)` (env var); internal services get `container_name` for DNS discovery, no labels, no ports.

#### Scenario: External service gets Traefik labels with env var

- **WHEN** user selects `service_type: external` and scaffolds
- **THEN** generated docker-compose includes Traefik labels with router rule using `${TRAEFIK_HOST}` (resolved at deploy time from `.env`)

#### Scenario: Internal service gets container name

- **WHEN** user selects `service_type: internal` and scaffolds
- **THEN** generated docker-compose has `container_name: {{ project_slug }}` and no Traefik labels

### Requirement: GitHub Actions CI/CD

The system SHALL generate `.github/workflows/ci-cd.yml` with `build-and-push` and `deploy` jobs matching the Go template pattern. The deploy job SHALL include env mapping (main → prod, dev → dev), TRAEFIK_HOST computation from convention, and Ansible task to write `.env` before `docker compose up`. Required secrets: `TAILSCALE_AUTHKEY`, `GITHUB_TOKEN`, `DEPLOY_REGISTRY_TOKEN`, `ANSIBLE_SSH_PRIVATE_KEY`, `DEPLOY_HOST`, `DEPLOY_USER`.

#### Scenario: Push to main triggers deploy

- **WHEN** code is pushed to `main` branch
- **THEN** build-and-push runs, then deploy job runs with prod TRAEFIK_HOST
