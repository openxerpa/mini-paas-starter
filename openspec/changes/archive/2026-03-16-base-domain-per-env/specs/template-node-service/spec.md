## MODIFIED Requirements

### Requirement: Cookiecutter variables for Node template

The system SHALL provide `templates/node-service/cookiecutter.json` with `project_name`, `project_slug`, `description`, `github_org`, `service_type` (external/internal), `service_port`, `docker_registry`, `base_domain_dev`, `base_domain_test`, `base_domain_prod`, and `memory_limit`. The system SHALL NOT include `base_domain` or `traefik_host`.

#### Scenario: Cruft prompts for variables

- **WHEN** user runs `cruft create ./templates/node-service`
- **THEN** user is prompted for project_name, description, github_org, service_type, service_port, base_domain_dev, base_domain_test, base_domain_prod, memory_limit

### Requirement: GitHub Actions CI/CD

The system SHALL generate `.github/workflows/ci-cd.yml` with `build-and-push` and `deploy` jobs matching the Go template pattern. The deploy job SHALL include env mapping (main → prod, dev → dev, test → test), TRAEFIK_HOST computation from per-env base domain, and Ansible task to write `.env` before `docker compose up`. Workflow SHALL trigger on push to `main`, `dev`, and `test` branches.

#### Scenario: Push to main triggers deploy

- **WHEN** code is pushed to `main` branch
- **THEN** build-and-push runs, then deploy job runs with prod TRAEFIK_HOST from base_domain_prod
