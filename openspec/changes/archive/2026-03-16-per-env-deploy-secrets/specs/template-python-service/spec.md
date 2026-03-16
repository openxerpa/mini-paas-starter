## MODIFIED Requirements

### Requirement: GitHub Actions CI/CD (per-env secrets)

The system SHALL generate `.github/workflows/ci-cd.yml` with deploy job using per-environment secrets: PROD_SERVER_IP/PROD_SSH_KEY (main), DEV_SERVER_IP/DEV_SSH_KEY (dev), TEST_SERVER_IP/TEST_SSH_KEY (test). Tailscale SHALL use TAILSCALE_OAUTH_CLIENT_ID and TAILSCALE_OAUTH_SECRET. DEPLOY_USER SHALL default to "deploy" when unset.

#### Scenario: main branch uses prod secrets

- **WHEN** push to main triggers deploy
- **THEN** inventory uses PROD_SERVER_IP, SSH key uses PROD_SSH_KEY

#### Scenario: test branch uses test secrets

- **WHEN** push to test triggers deploy
- **THEN** inventory uses TEST_SERVER_IP, SSH key uses TEST_SSH_KEY
