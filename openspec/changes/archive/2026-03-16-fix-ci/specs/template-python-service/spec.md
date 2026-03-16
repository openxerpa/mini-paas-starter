## MODIFIED Requirements

### Requirement: GitHub Actions CI/CD

The system SHALL generate `.github/workflows/ci-cd.yml` with `build-and-push` job (checkout via `actions/checkout@v6`, ghcr.io login, build with layer cache, push latest + SHA) and `deploy` job (Tailscale setup via `tailscale/github-action@v4` with `authkey` parameter, Ansible inline playbook for copy compose, docker login, pull & up). Required secrets: `TAILSCALE_AUTHKEY`, `GITHUB_TOKEN`, `DEPLOY_REGISTRY_TOKEN`, `ANSIBLE_SSH_PRIVATE_KEY`, `DEPLOY_HOST`, `DEPLOY_USER`.

#### Scenario: Push to main triggers deploy

- **WHEN** code is pushed to `main` branch
- **THEN** build-and-push runs, then deploy job runs with inline Ansible playbook

#### Scenario: Tailscale uses authkey parameter

- **WHEN** deploy job runs Setup Tailscale step
- **THEN** workflow uses `authkey: ${{ secrets.TAILSCALE_AUTHKEY }}` (not `auth-key`)
