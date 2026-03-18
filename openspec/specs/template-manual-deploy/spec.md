### Requirement: Manual deploy workflow triggers on manual dispatch only

The generated templates SHALL include `.github/workflows/manual-deploy.yml` that triggers only on `workflow_dispatch`. The workflow SHALL NOT trigger on push or any other event.

#### Scenario: Manual trigger runs workflow

- **WHEN** a user triggers the workflow from GitHub Actions UI
- **THEN** the workflow runs
- **AND** no automatic trigger (push, schedule, etc.) starts the workflow

#### Scenario: Push does not trigger manual deploy

- **WHEN** code is pushed to any branch
- **THEN** the manual-deploy workflow does NOT run
- **AND** only the main ci-cd workflow may run (per its own triggers)

### Requirement: Manual deploy accepts image tag and target environment

The manual-deploy workflow SHALL accept two required inputs: `image_tag` (string, the Docker image tag to deploy, e.g. `v1.0.0` or `dev-latest`) and `target_env` (string or choice: `production`, `dev`, `test`, or `dev-<username>` for developer environments, e.g. `dev-alice`, `dev-bob`).

#### Scenario: User provides inputs

- **WHEN** the user triggers the workflow
- **THEN** they MUST provide `image_tag` and `target_env`
- **AND** the workflow uses these values for the deploy step

#### Scenario: target_env maps to per-env secrets

- **WHEN** `target_env` is `production`
- **THEN** the deploy job selects `PROD_TAILSCALE_IP` and `PROD_SSH_KEY` via case/if
- **AND** no `environment:` is declared

#### Scenario: Developer environment uses dev secrets

- **WHEN** `target_env` is `dev-alice`
- **THEN** the deploy job selects `DEV_TAILSCALE_IP` and `DEV_SSH_KEY` (shared dev server)
- **AND** secrets are repo-level, not environment-scoped

### Requirement: Manual deploy resolves traefik_host and deploy_dir from target_env

The workflow SHALL map `target_env` to `traefik_host` and `deploy_dir` per the routing convention `{app}.{env}.domain.com`:

| target_env | traefik_host | deploy_dir |
|------------|--------------|------------|
| production | `<slug>.<base_domain_prod>` | `/opt/apps/<slug>` |
| dev | `<slug>.dev.<base_domain_dev>` | `/opt/apps/<slug>` |
| test | `<slug>.test.<base_domain_test>` | `/opt/apps/<slug>` |
| dev-&lt;username&gt; | `<slug>-<username>.dev.<base_domain_dev>` | `/opt/apps/<slug>-dev-<username>` |

#### Scenario: Production traefik host

- **WHEN** `target_env` is `production`
- **THEN** `traefik_host` is `<slug>.<base_domain_prod>`

#### Scenario: Dev traefik host

- **WHEN** `target_env` is `dev`
- **THEN** `traefik_host` is `<slug>.dev.<base_domain_dev>`

#### Scenario: Developer environment traefik host

- **WHEN** `target_env` is `dev-alice`
- **THEN** `traefik_host` is `<slug>-alice.dev.<base_domain_dev>`
- **AND** `deploy_dir` is `/opt/apps/<slug>-dev-alice`

### Requirement: Manual deploy runs deploy-only (no build, no test)

The manual-deploy workflow SHALL run only the deploy step. It SHALL NOT run test or build-and-push jobs. It SHALL use the existing `.github/deploy.yml` playbook and pass the user-provided `image_tag` to the playbook.

#### Scenario: Deploy uses existing image

- **WHEN** the workflow runs
- **THEN** it invokes `ansible-playbook` with `-e image_tag=<user input>`
- **AND** the playbook performs `docker compose pull` for that tag

#### Scenario: No build or test jobs

- **WHEN** the workflow runs
- **THEN** it has no test job
- **AND** it has no build-and-push job
