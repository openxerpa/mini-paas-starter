## ADDED Requirements

### Requirement: Root README overview and quick start

The system SHALL provide `README.md` at repo root with project overview, target audience, prerequisites (Docker, Ansible, Tailscale, Cruft/Cookiecutter), and quick start workflows: bootstrap server, configure Traefik `.env`, deploy Traefik, scaffold app via `cruft create ./templates/go-service`.

#### Scenario: New user follows quick start

- **WHEN** user reads README and follows quick start steps
- **THEN** they can bootstrap a server, deploy Traefik, and scaffold a Go service

### Requirement: Directory overview in README

The system SHALL include a directory overview table in root README describing `infra/`, `templates/`, `docs/` and their contents.

#### Scenario: User navigates structure

- **WHEN** user reads README
- **THEN** they understand where Traefik config, Ansible playbooks, and templates live

### Requirement: Link to architecture doc

The system SHALL link from root README to `docs/architecture.md`.

#### Scenario: User finds architecture

- **WHEN** user clicks README link
- **THEN** they reach `docs/architecture.md`

### Requirement: Architecture document content

The system SHALL provide `docs/architecture.md` covering vision and core advantages (zero-agent, zero-trust, zero-config routing), tech stack overview, traffic flows (CI/CD, north-south, east-west) in text/ASCII, infrastructure setup reference, application integration patterns, and capacity planning/ops guidelines.

#### Scenario: Operator understands traffic flow

- **WHEN** operator reads `docs/architecture.md`
- **THEN** they understand how CI/CD, external traffic, and internal service-to-service traffic flow

### Requirement: Generated project README

Each scaffolded project SHALL include a README with service description (from `cookiecutter.description`), local development (`docker compose up`), deployment (push to main, CI/CD handles rest), and environment variables reference.

#### Scenario: Scaffolded project has usable README

- **WHEN** user scaffolds a new service
- **THEN** generated README explains how to run locally and deploy
