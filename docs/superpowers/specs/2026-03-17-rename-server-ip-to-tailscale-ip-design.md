# Rename SERVER_IP to TAILSCALE_IP

## Context

The deploy job uses server IPs for Ansible SSH. These IPs are Tailscale-assigned (100.x.x.x); SSH runs over the Tailscale mesh and servers typically have no public SSH port. The current naming (`PROD_SERVER_IP`, `TEST_SERVER_IP`, etc.) does not make this explicit.

## Design Decision

**Rename** `*_SERVER_IP` → `*_TAILSCALE_IP` and **add documentation** that these must be Tailscale IPs.

**Use per-env variable names** because the GitHub org does not use GitHub Environments. Secrets are repo-level; the workflow selects the correct secret based on branch/env via case/if logic. Both CI/CD and emergency deploy follow this model: no `environment:` declaration; case/if selects `PROD_TAILSCALE_IP`, `DEV_TAILSCALE_IP`, or `TEST_TAILSCALE_IP` (and corresponding `*_SSH_KEY`) based on env.

## Variable Naming

| Variable | Purpose |
|----------|---------|
| `PROD_TAILSCALE_IP` | Production server Tailscale IP |
| `DEV_TAILSCALE_IP` | Dev server Tailscale IP |
| `TEST_TAILSCALE_IP` | Test server Tailscale IP |
| `PROD_SSH_KEY` | Production SSH private key |
| `DEV_SSH_KEY` | Dev SSH private key |
| `TEST_SSH_KEY` | Test SSH private key |

SSH key names stay as-is; only the IP variable is renamed.

## Documentation

Add to relevant docs:

> These IP variables must be the target server's Tailscale IP (100.x.x.x). Do not use public IPs. SSH connects over Tailscale; servers typically do not expose public SSH ports.

## Scope

### CI workflow templates

- `templates/go-service/{{cookiecutter.project_slug}}/.github/workflows/ci-cd.yml`
- `templates/node-service/{{cookiecutter.project_slug}}/.github/workflows/ci-cd.yml`
- `templates/python-service/{{cookiecutter.project_slug}}/.github/workflows/ci-cd.yml`

Remove `environment:`; use case/if to select `secrets.PROD_TAILSCALE_IP`, `secrets.DEV_TAILSCALE_IP`, or `secrets.TEST_TAILSCALE_IP` (and `*_SSH_KEY`) based on `needs.prepare.outputs.env_name`.

### Emergency deploy workflows

- `templates/go-service/{{cookiecutter.project_slug}}/.github/workflows/emergency-deploy.yml`
- `templates/node-service/{{cookiecutter.project_slug}}/.github/workflows/emergency-deploy.yml`
- `templates/python-service/{{cookiecutter.project_slug}}/.github/workflows/emergency-deploy.yml`

Same model: remove `environment:`; use case/if on `inputs.target_env` to select `PROD_TAILSCALE_IP`, `DEV_TAILSCALE_IP`, or `TEST_TAILSCALE_IP`. For `dev-<username>`, map to `DEV_TAILSCALE_IP` (shared dev server) or document that per-developer envs require GitHub Environments.

### Template READMEs

- `templates/go-service/{{cookiecutter.project_slug}}/README.md`
- `templates/node-service/{{cookiecutter.project_slug}}/README.md`
- `templates/python-service/{{cookiecutter.project_slug}}/README.md`

Replace "GitHub Environments setup" with "Repo-level secrets": list `PROD_TAILSCALE_IP`, `DEV_TAILSCALE_IP`, `TEST_TAILSCALE_IP` (and `*_SSH_KEY`). Change `SERVER_IP` → `TAILSCALE_IP` in descriptions. Add the Tailscale IP documentation note.

### Documentation

- `docs/sample-app-cicd-walkthrough.md`
- `docs/architecture.md`
- `docs/superpowers/specs/2026-03-17-refactor-ci-cd-design.md` (if still relevant)

### OpenSpec

- `openspec/specs/template-ci-workflow/spec.md` — update deploy requirement: use per-env repo-level secrets (`PROD_TAILSCALE_IP`, `DEV_TAILSCALE_IP`, `TEST_TAILSCALE_IP`, `*_SSH_KEY`) with case/if selection; remove requirement for `environment:` and environment-scoped secrets.
- `openspec/specs/template-emergency-deploy/spec.md` — update scenario text: `SERVER_IP` → `TAILSCALE_IP` (or per-env names); align with per-env repo-level model when Environments are not used.

## Implementation Notes

- No migration guide (project not yet in use).
