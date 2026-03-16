## ADDED Requirements

### Requirement: Prepare job resolves branch to environment

The generated CI workflow SHALL include a `prepare` job that maps the branch (`main`, `dev`, `test`) to environment outputs. The job SHALL output `env_name`, `traefik_host`, and `image_tag_prefix` to `$GITHUB_OUTPUT`. For unsupported branches, the job SHALL exit with code 1 and emit an error.

#### Scenario: main branch resolves to production

- **WHEN** the workflow runs on branch `main`
- **THEN** the prepare job outputs `env_name=production`, `image_tag_prefix=prod`, and `traefik_host=<slug>.<base_domain_prod>`

#### Scenario: dev branch resolves to dev

- **WHEN** the workflow runs on branch `dev`
- **THEN** the prepare job outputs `env_name=dev`, `image_tag_prefix=dev`, and `traefik_host=<slug>.dev.<base_domain_dev>`

#### Scenario: test branch resolves to test

- **WHEN** the workflow runs on branch `test`
- **THEN** the prepare job outputs `env_name=test`, `image_tag_prefix=test`, and `traefik_host=<slug>.test.<base_domain_test>`

#### Scenario: Unsupported branch fails

- **WHEN** the workflow runs on a branch other than `main`, `dev`, or `test`
- **THEN** the prepare job exits with code 1 and the workflow fails

### Requirement: Test job runs before build

The generated CI workflow SHALL include a `test` job that runs language-specific tests. The test job SHALL depend on `prepare` and SHALL use dependency caching. Empty test suites SHALL not fail the job (Go: exit 0 on no tests; Node: placeholder test; Python: pytest exit 5 treated as success).

#### Scenario: Test job runs on push

- **WHEN** the workflow runs on a supported branch
- **THEN** the test job runs after prepare and before build-and-push
- **AND** tests use the language-appropriate runner (setup-go, setup-node+pnpm, or setup-uv)

### Requirement: Build pushes environment-scoped image tags

The generated CI workflow SHALL push Docker images with environment-scoped tags. Tags SHALL include `<prefix>-latest` and `<prefix>-<short-sha>`. The prefix SHALL come from the prepare job output (`image_tag_prefix`).

#### Scenario: Dev branch pushes dev-scoped tags

- **WHEN** the build-and-push job runs on branch `dev` with SHA abc1234
- **THEN** the image is tagged `:dev-latest` and `:dev-abc1234`
- **AND** no tag collision occurs with other branches

### Requirement: Deploy job uses GitHub Environments

The deploy job SHALL declare `environment: ${{ needs.prepare.outputs.env_name }}`. Secrets SHALL be environment-scoped (`SSH_KEY`, `SERVER_IP`, `DEPLOY_USER` per environment). `DEPLOY_USER` SHALL default to `root` when not set.

#### Scenario: Production deploy uses production environment

- **WHEN** the deploy job runs for branch `main`
- **THEN** the job uses `environment: production`
- **AND** secrets are read from the production environment

### Requirement: Deploy uses committed Ansible playbook

The generated CI workflow SHALL invoke a committed Ansible playbook at `.github/deploy.yml`. The playbook SHALL create the deploy directory, copy docker-compose.yml, write .env with TRAEFIK_HOST and IMAGE_TAG, perform registry login when token is set, run `docker compose pull && docker compose up -d`, and verify container running status.

#### Scenario: Playbook is committed and invoked

- **WHEN** the deploy job runs
- **THEN** it invokes `ansible-playbook -i <inventory> .github/deploy.yml` with extra vars
- **AND** the playbook file exists in the repository at `.github/deploy.yml`

### Requirement: docker-compose image tag is configurable

The generated `docker-compose.yml` SHALL use `IMAGE_TAG` environment variable for the image tag, with `latest` as default when unset.

#### Scenario: Local development uses default tag

- **WHEN** `docker compose up` runs without IMAGE_TAG set
- **THEN** the image uses `:latest`

#### Scenario: CI deploy injects env-scoped tag

- **WHEN** the deploy playbook writes .env
- **THEN** it sets `IMAGE_TAG=<prefix>-latest` (e.g., `prod-latest`)

## MODIFIED Requirements

### Requirement: Deploy step locates docker-compose.yml correctly

The generated CI workflow SHALL pass the absolute path to `docker-compose.yml` to the Ansible deploy playbook so the copy task can find the file. The workflow invokes the committed playbook at `.github/deploy.yml`; the file lives in the repo checkout (`$GITHUB_WORKSPACE`).

#### Scenario: Deploy step copies docker-compose.yml

- **WHEN** the deploy job runs and executes the Ansible copy task
- **THEN** the playbook receives `compose_src` set to `$GITHUB_WORKSPACE/docker-compose.yml` via extra vars
- **AND** the file is found and copied to the deploy directory on the target host
