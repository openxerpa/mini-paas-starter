## MODIFIED Requirements

### Requirement: Cookiecutter variables for Go template

The system SHALL provide `templates/go-service/cookiecutter.json` with `project_name`, `project_slug`, `description`, `github_org`, `service_type` (external/internal), `service_port`, `docker_registry`, `base_domain`, and `memory_limit`. The system SHALL NOT include `traefik_host`.

#### Scenario: Cruft prompts for variables

- **WHEN** user runs `cruft create ./templates/go-service`
- **THEN** user is prompted for project_name, description, github_org, service_type, service_port, base_domain, memory_limit

### Requirement: docker-compose with service type support

The system SHALL generate `docker-compose.yml` with `traefik_webgateway` external network, `deploy.resources.limits.memory` from `memory_limit`, and Jinja2 conditionals: external services get Traefik labels with router rule `Host(\`${TRAEFIK_HOST}\`)` (env var); internal services get `container_name` for DNS discovery, no labels, no ports.

#### Scenario: External service gets Traefik labels with env var

- **WHEN** user selects `service_type: external` and scaffolds
- **THEN** generated docker-compose includes Traefik labels with router rule using `${TRAEFIK_HOST}` (resolved at deploy time from `.env`)

#### Scenario: Internal service gets container name

- **WHEN** user selects `service_type: internal` and scaffolds
- **THEN** generated docker-compose has `container_name: {{ project_slug }}` and no Traefik labels; other services call via `http://<slug>:<port>`

### Requirement: GitHub Actions CI/CD

The system SHALL generate `.github/workflows/ci-cd.yml` with `build-and-push` job (checkout, ghcr.io login, build with layer cache, push latest + SHA) and `deploy` job. The deploy job SHALL: (1) determine env from branch (main → prod, dev → dev) with clearly commented logic for app customization; (2) compute `TRAEFIK_HOST` from convention (prod: `{slug}.{base_domain}`, dev: `{slug}-dev.{base_domain}`); (3) include Ansible task to write `.env` with `TRAEFIK_HOST` to deploy dir before `docker compose up`; (4) Tailscale setup, inline Ansible playbook for copy compose, docker login, pull & up. Required secrets: `TAILSCALE_AUTHKEY`, `GITHUB_TOKEN`, `DEPLOY_REGISTRY_TOKEN`, `ANSIBLE_SSH_PRIVATE_KEY`, `DEPLOY_HOST`, `DEPLOY_USER`.

#### Scenario: Push to main triggers deploy with prod domain

- **WHEN** code is pushed to `main` branch
- **THEN** build-and-push runs, deploy job sets env=prod, TRAEFIK_HOST={slug}.{base_domain}, writes .env, runs docker compose up

#### Scenario: Push to dev triggers deploy with dev domain

- **WHEN** code is pushed to `dev` branch
- **THEN** deploy job sets env=dev, TRAEFIK_HOST={slug}-dev.{base_domain}, writes .env, runs docker compose up
