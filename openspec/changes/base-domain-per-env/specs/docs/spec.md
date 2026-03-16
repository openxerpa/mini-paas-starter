## MODIFIED Requirements

### Requirement: Sample app CI/CD walkthrough document

The system SHALL provide `docs/sample-app-cicd-walkthrough.md` with step-by-step instructions for infra-ready users to run scaffold → CI/CD deploy successfully. The document SHALL cover: (1) brief note that infra manages bootstrap, Traefik, Tailscale, and CI secrets; (2) Step 1: scaffold with cruft from Go template, prompt for base_domain_dev, base_domain_test, base_domain_prod (e.g. test: a.com, prod: c.com); (3) Step 2: confirm infra-configured secrets, add project-specific vars if needed; (4) Step 3: create GitHub repo, push to main/dev/test; (5) Step 4: verify deployment (external: curl per-env domain, internal: curl from Tailscale network); (6) troubleshooting for build/deploy/access failures.

#### Scenario: User follows walkthrough to deploy

- **WHEN** infra-ready user follows `docs/sample-app-cicd-walkthrough.md`
- **THEN** they can scaffold a Go service with per-env base domains, push to main/dev/test, and verify it is deployed and reachable at the correct domain per environment
