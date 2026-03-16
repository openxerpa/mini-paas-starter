## ADDED Requirements

### Requirement: Bootstrap playbook initializes server

The system SHALL provide `playbooks/bootstrap.yml` that installs Docker Engine and Docker Compose plugin via official Docker apt repo, creates `traefik_webgateway` external network, configures Docker daemon log rotation (`max-size: 50m`, `max-file: 3`), creates `/opt/apps/`, and restarts Docker. The playbook SHALL be idempotent.

#### Scenario: Fresh server bootstrap

- **WHEN** operator runs `ansible-playbook playbooks/bootstrap.yml` on a fresh server
- **THEN** Docker is installed, `traefik_webgateway` network exists, `/opt/apps/` exists, and daemon.json has log rotation configured

#### Scenario: Re-run is safe

- **WHEN** operator re-runs bootstrap playbook on an already bootstrapped server
- **THEN** no errors occur and state remains correct

### Requirement: Tailscale playbook joins mesh

The system SHALL provide `playbooks/tailscale.yml` that installs Tailscale via official package repo, authenticates with auth key passed as `--extra-vars "tailscale_auth_key=tskey-..."`, enables IP forwarding if needed, and verifies connectivity via `tailscale status`.

#### Scenario: Server joins Tailscale

- **WHEN** operator runs playbook with valid `tailscale_auth_key` extra var
- **THEN** node appears in `tailscale status` as connected

### Requirement: Traefik playbook deploys gateway

The system SHALL provide `playbooks/traefik.yml` that ensures `/opt/traefik/` exists, copies `infra/traefik/docker-compose.yml` and `infra/traefik/.env` to server, and runs `docker compose pull && docker compose up -d`.

#### Scenario: Traefik deployed via Ansible

- **WHEN** operator runs `ansible-playbook playbooks/traefik.yml` after creating `.env` from `.env.example`
- **THEN** Traefik runs in `/opt/traefik/` on the target server

### Requirement: Deploy-app playbook deploys any service

The system SHALL provide `playbooks/deploy-app.yml` that accepts `app_name`, `compose_src`, and `gh_token` via `--extra-vars`, ensures `/opt/apps/{{ app_name }}/` exists, copies compose file to server, logs in to registry, and runs `docker compose pull && docker compose up -d`. Target environment SHALL be selected via `-l <group>`.

#### Scenario: Deploy app to production

- **WHEN** operator runs `ansible-playbook -i inventory/hosts.yml playbooks/deploy-app.yml -l production -e "app_name=my-service compose_src=/path/to/docker-compose.yml gh_token=ghp_..."`
- **THEN** app is deployed to `/opt/apps/my-service/` on production hosts

### Requirement: Inventory and group_vars

The system SHALL provide `inventory/hosts.yml` with groups by environment (e.g. production, staging) and Tailscale IPs as `ansible_host`. The system SHALL provide `inventory/group_vars/all.yml` with `deploy_base_dir`, `docker_registry`, `docker_log_max_size`, `docker_log_max_file`, `traefik_deploy_dir`.

#### Scenario: Inventory targets correct hosts

- **WHEN** operator runs playbook with `-l production`
- **THEN** only production hosts are targeted via their Tailscale IPs

### Requirement: Ansible configuration

The system SHALL provide `ansible.cfg` with default inventory `inventory/hosts.yml`, SSH pipelining enabled, and host key checking disabled.

#### Scenario: Ansible uses correct config

- **WHEN** operator runs `ansible-playbook` from `infra/ansible/`
- **THEN** inventory and pipelining are applied by default
