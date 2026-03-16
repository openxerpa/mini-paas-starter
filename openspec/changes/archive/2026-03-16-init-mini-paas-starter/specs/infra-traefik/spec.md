## ADDED Requirements

### Requirement: Traefik gateway runs via Docker Compose

The system SHALL provide `infra/traefik/docker-compose.yml` that runs Traefik v3 with `restart: unless-stopped`, security hardening (`no-new-privileges: true`, `cap_drop: ALL`, `cap_add: NET_BIND_SERVICE`), and read-only Docker socket mount.

#### Scenario: Traefik starts with correct security settings

- **WHEN** operator runs `docker compose up -d` in `infra/traefik/`
- **THEN** Traefik container starts with no-new-privileges, cap_drop ALL, cap_add NET_BIND_SERVICE, and `/var/run/docker.sock` mounted read-only

#### Scenario: Traefik uses external webgateway network

- **WHEN** Traefik compose stack is started
- **THEN** it attaches to external network `traefik_webgateway` (created by bootstrap playbook)

### Requirement: Traefik exposes web and dashboard entrypoints

The system SHALL configure Traefik with entrypoint `web` on port 80 and entrypoint `dashboard` on port 8080. The dashboard host SHALL be read from `${TRAEFIK_DASHBOARD_HOST}` env var.

#### Scenario: Web traffic accepted on port 80

- **WHEN** HTTP request is sent to port 80
- **THEN** Traefik routes it via the `web` entrypoint

#### Scenario: Dashboard accessible on port 8080

- **WHEN** request is sent to port 8080 with Host matching `TRAEFIK_DASHBOARD_HOST`
- **THEN** Traefik dashboard is served

### Requirement: Traefik Docker provider configuration

The system SHALL configure the Docker provider with `exposedbydefault=false` and `network=traefik_webgateway`.

#### Scenario: Only labeled containers are exposed

- **WHEN** a container is started without Traefik labels
- **THEN** Traefik does not route traffic to it

### Requirement: Traefik env example file

The system SHALL provide `infra/traefik/.env.example` containing `TRAEFIK_DASHBOARD_HOST=traefik.yourdomain.com` as the only env var.

#### Scenario: Operator copies env example

- **WHEN** operator runs `cp infra/traefik/.env.example infra/traefik/.env` and sets `TRAEFIK_DASHBOARD_HOST`
- **THEN** Traefik dashboard is routable at the configured host
