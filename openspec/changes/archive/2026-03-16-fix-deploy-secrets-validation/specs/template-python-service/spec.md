## ADDED Requirements

### Requirement: Deploy secrets validation

The system SHALL generate a "Validate deploy secrets" step in the deploy job, before "Run deploy", that checks required secrets are non-empty: DEPLOY_HOST, DEPLOY_USER, DEPLOY_REGISTRY_TOKEN, ANSIBLE_SSH_PRIVATE_KEY, TS_OAUTH_CLIENT_ID, TS_OAUTH_SECRET. If any are missing, the step SHALL fail with an error listing the missing secret names.

#### Scenario: Missing DEPLOY_HOST fails early

- **WHEN** DEPLOY_HOST secret is empty and deploy job runs
- **THEN** "Validate deploy secrets" step fails with error listing DEPLOY_HOST before Ansible runs

#### Scenario: All secrets set proceeds to deploy

- **WHEN** all required secrets are set
- **THEN** validation step passes and "Run deploy" runs
