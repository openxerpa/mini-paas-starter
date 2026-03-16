## MODIFIED Requirements

### Requirement: Cookiecutter variables for Go template

The system SHALL provide `templates/go-service/cookiecutter.json` with `project_name`, `project_slug`, `description`, `github_org`, `service_type` (external/internal), `service_port`, `docker_registry`, `base_domain_dev`, `base_domain_test`, `base_domain_prod`, and `memory_limit`. The system SHALL NOT include `base_domain` or `traefik_host`.

#### Scenario: Cruft prompts for variables

- **WHEN** user runs `cruft create ./templates/go-service`
- **THEN** user is prompted for project_name, description, github_org, service_type, service_port, base_domain_dev, base_domain_test, base_domain_prod, memory_limit

### Requirement: GitHub Actions CI/CD

The system SHALL generate `.github/workflows/ci-cd.yml` with `build-and-push` job (checkout, ghcr.io login, build with layer cache, push latest + SHA) and `deploy` job. The deploy job SHALL: (1) determine env from branch (main → prod, dev → dev, test → test) with clearly commented logic for app customization; (2) compute `TRAEFIK_HOST` from per-env base domain (prod: `{slug}.{base_domain_prod}`, dev: `{slug}-dev.{base_domain_dev}`, test: `{slug}-test.{base_domain_test}`); (3) include Ansible task to write `.env` with `TRAEFIK_HOST` to deploy dir before `docker compose up`; (4) Tailscale setup, inline Ansible playbook for copy compose, docker login, pull & up. Required secrets: `TAILSCALE_AUTHKEY`, `GITHUB_TOKEN`, `DEPLOY_REGISTRY_TOKEN`, `ANSIBLE_SSH_PRIVATE_KEY`, `DEPLOY_HOST`, `DEPLOY_USER`. Workflow SHALL trigger on push to `main`, `dev`, and `test` branches.

#### Scenario: Push to main triggers deploy with prod domain

- **WHEN** code is pushed to `main` branch
- **THEN** build-and-push runs, deploy job sets env=prod, TRAEFIK_HOST={slug}.{base_domain_prod}, writes .env, runs docker compose up

#### Scenario: Push to dev triggers deploy with dev domain

- **WHEN** code is pushed to `dev` branch
- **THEN** deploy job sets env=dev, TRAEFIK_HOST={slug}-dev.{base_domain_dev}, writes .env, runs docker compose up

#### Scenario: Push to test triggers deploy with test domain

- **WHEN** code is pushed to `test` branch
- **THEN** deploy job sets env=test, TRAEFIK_HOST={slug}-test.{base_domain_test}, writes .env, runs docker compose up
