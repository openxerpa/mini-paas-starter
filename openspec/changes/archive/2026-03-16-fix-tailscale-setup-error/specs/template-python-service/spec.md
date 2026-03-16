## MODIFIED Requirements

### Requirement: GitHub Actions CI/CD

The system SHALL generate `.github/workflows/ci-cd.yml` with `build-and-push` job (checkout via `actions/checkout@v6`, ghcr.io login, build with layer cache, push latest + SHA) and `deploy` job (Tailscale setup via `tailscale/github-action@v4` with OAuth: `oauth-client-id`, `oauth-secret`, `tags: tag:ci`, Ansible inline playbook for copy compose, docker login, pull & up). Required secrets: `TS_OAUTH_CLIENT_ID`, `TS_OAUTH_SECRET`, `GITHUB_TOKEN`, `DEPLOY_REGISTRY_TOKEN`, `ANSIBLE_SSH_PRIVATE_KEY`, `DEPLOY_HOST`, `DEPLOY_USER`.

#### Scenario: Push to main triggers deploy

- **WHEN** code is pushed to `main` branch
- **THEN** build-and-push runs, then deploy job runs with inline Ansible playbook

#### Scenario: Tailscale uses OAuth

- **WHEN** deploy job runs Setup Tailscale step
- **THEN** workflow uses `oauth-client-id`, `oauth-secret`, and `tags: tag:ci` (not deprecated authkey)
