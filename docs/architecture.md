# Mini PaaS Starter — Architecture

## Vision

A minimal PaaS for small R&D teams (1–10 people) that provides:

- **Zero-agent**: No sidecar or daemon on app containers; Traefik discovers services via Docker labels
- **Zero-trust**: Tailscale mesh for SSH and internal traffic; no public SSH ports
- **Zero-config routing**: External services get Traefik labels; internal services use Docker DNS (`http://service-name:port`)

## Tech stack

| Component | Role |
|-----------|------|
| Docker & Compose | Container runtime, app packaging |
| Traefik v3 | Reverse proxy, HTTP routing, service discovery |
| Tailscale | VPN mesh, zero-trust SSH access |
| Ansible | Server bootstrap, Traefik deploy, app deploy |
| GitHub Actions | Build images, deploy via Tailscale + Ansible |

## Traffic flows

### CI/CD flow

```
Developer push → GitHub Actions
  → Build Docker image → Push to ghcr.io
  → Tailscale join (ephemeral)
  → Ansible over Tailscale → docker compose pull && up
```

### North-south (external traffic)

```
Internet → Cloud LB/CDN (TLS) → Traefik:80 → App container
```

Traefik is HTTP-only; TLS is terminated upstream by cloud LB or CDN.

### East-west (internal traffic)

```
Internal service A → Docker DNS (service-name:port) → Service B container
```

Internal services share the `traefik_webgateway` network. No Traefik labels; call via `http://<container_name>:<port>`.

## Infrastructure setup

1. **Bootstrap**: Install Docker, create `traefik_webgateway` network, configure daemon.json, create `/opt/apps/`
2. **Tailscale**: Install and join mesh; server gets a Tailscale IP
3. **Traefik**: Copy compose + .env to `/opt/traefik/`, run `docker compose up -d`
4. **Apps**: Deploy via `deploy-app.yml` or CI/CD

## Application integration

### External service

- `service_type: external`
- Traefik labels: `traefik.enable=true`, router rule with `traefik_host`
- Reachable from internet (via Traefik) at configured host

### Internal service

- `service_type: internal`
- `container_name: <slug>` for stable DNS
- No Traefik labels; other services call `http://<slug>:<port>`

## Capacity planning

- **Single server**: Suitable for 5–15 small services; monitor memory and CPU
- **Multi-server**: Add hosts to inventory groups; each server runs its own Traefik + apps
- **Scaling**: Horizontal scaling via multiple instances in inventory; consider load balancing for high traffic

## Ops guidelines

- **Secrets**: Never commit `tailscale_auth_key`, `gh_token`, or `DEPLOY_REGISTRY_TOKEN`; use `--extra-vars` or GitHub secrets
- **Dashboard**: Traefik dashboard on port 8080; restrict via cloud firewall to internal/Tailscale IPs only
- **Idempotency**: All Ansible playbooks are safe to re-run
- **Rollback**: `docker compose down` in app dir; re-run deploy playbook for previous version
