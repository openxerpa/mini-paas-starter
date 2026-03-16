## ADDED Requirements

### Requirement: Optional registry token

The deploy playbook SHALL run `docker login` only when `deploy_registry_token` is non-empty. When empty, the playbook SHALL skip the login task and proceed directly to `docker compose pull && docker compose up -d`. This allows deploying public registry images without DEPLOY_REGISTRY_TOKEN.

#### Scenario: Token set runs docker login

- **WHEN** DEPLOY_REGISTRY_TOKEN secret is set and deploy runs
- **THEN** playbook runs docker login before pull & up

#### Scenario: Token empty skips docker login

- **WHEN** DEPLOY_REGISTRY_TOKEN is empty and deploy runs
- **THEN** playbook skips docker login and runs pull & up (works for public images)
