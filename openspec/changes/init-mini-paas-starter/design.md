## Context

A monorepo providing infrastructure configs and Cookiecutter/Cruft project templates for a minimal PaaS targeting 1–10 person R&D teams. Teams get production-grade Docker + Traefik + Tailscale + Ansible infrastructure with zero-config service discovery, and can scaffold new Go/Node.js/Python services in seconds via `cruft create`.

**Core tech stack:** Docker & Docker Compose, Traefik v3, Tailscale, Ansible, GitHub Actions.

## Goals / Non-Goals

**Goals:**
- Provide idempotent Ansible playbooks for full server lifecycle (bootstrap → Traefik → Tailscale → deploy)
- Traefik v3 gateway with Docker provider, HTTP-only (TLS upstream), security hardening
- Three language templates (Go, Node, Python) with stdlib-only skeletons, shared cookiecutter variables, and `service_type` (external/internal) toggle
- GitHub Actions CI/CD in each template: build-and-push + deploy via Tailscale + inline Ansible
- Clear docs: root README quick start, `docs/architecture.md` with traffic flows

**Non-Goals:**
- TLS termination in Traefik (handled by cloud LB/CDN)
- Framework-specific app code (teams add their own after scaffolding)
- Kubernetes or multi-cluster orchestration
- Conditional Cookiecutter prompting (traefik_host always prompted, ignored when internal)

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Repo structure | Flat monorepo | Simplest for small teams; trivial to split later |
| Template scope | App skeleton + Dockerfile + docker-compose + CI/CD | Enough to deploy; not so much that it's opinionated |
| Ansible scope | Full lifecycle (bootstrap, Traefik, Tailscale, deploy) | Team can go from bare server to running services |
| HTTPS/TLS | HTTP-only in Traefik | TLS terminated upstream by cloud LB or CDN |
| Service type | Single template per language, `service_type` toggle | DRY; avoids 6 near-duplicate templates |
| App dependencies | Stdlib-only skeletons | Teams add their own frameworks after scaffolding |
| Traefik config | Compose `command` args only | No separate static config file; minimal enough |
| Dashboard auth | None | Access restricted by cloud firewall limiting port 8080 to internal/Tailscale IPs |

**Alternatives considered:**
- **Kubernetes**: Rejected—too heavy for 1–10 person teams
- **Separate templates per service_type**: Rejected—Jinja2 conditionals in one template are DRY
- **Traefik static config file**: Rejected—compose command args suffice for this scope

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Dashboard exposed without auth | Cloud firewall restricts port 8080 to internal/Tailscale IPs only |
| `gh_token` / `DEPLOY_REGISTRY_TOKEN` in CI | Document as GitHub PAT with `read:packages`; never stored in repo |
| Tailscale auth key in CI | Ephemeral key via `TAILSCALE_AUTHKEY` secret; never committed |
| Single server bottleneck | Document capacity planning; design supports multiple servers via inventory groups |

## Migration Plan

- **Initial setup**: Greenfield; no migration. Operator bootstraps server, configures Traefik `.env`, deploys gateway, then scaffolds apps.
- **Rollback**: Re-run playbooks idempotently; `docker compose down` for apps. No stateful migrations.

## Open Questions

- None. Design is complete per spec.
