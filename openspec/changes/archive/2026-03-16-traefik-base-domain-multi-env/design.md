## Context

Templates currently prompt for `traefik_host` at scaffold time and bake it into docker-compose. This forces app developers to know the exact domain per environment upfront. Infra manages domains uniformly; apps should scaffold once with `base_domain` and let CI derive `TRAEFIK_HOST` per environment (dev/prod). A sample-app walkthrough doc is needed for infra-ready users to run scaffold → CI/CD deploy.

## Goals / Non-Goals

**Goals:**
- Replace `traefik_host` with `base_domain` in all three templates
- Convention: prod = `{slug}.{base_domain}`, dev = `{slug}-dev.{base_domain}`
- CI computes `TRAEFIK_HOST` from branch (main → prod, dev → dev), writes `.env` before deploy
- docker-compose uses `${TRAEFIK_HOST}` in Traefik router rule
- Add `docs/sample-app-cicd-walkthrough.md` for scaffold → deploy (CI/CD path, Go example)
- CI structure allows app to customize env mapping and domain formula

**Non-Goals:**
- Changing infra playbooks or Traefik config
- Supporting more than dev/prod in the default template (app can add staging via CI edits)
- Modifying internal service behavior (no Traefik labels; unchanged)

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Domain convention | prod: `{slug}.{base}`, dev: `{slug}-dev.{base}` | Simple, predictable; prod gets clean domain |
| Env mapping | main → prod, dev → dev | Matches common branch strategy; app can change |
| TRAEFIK_HOST injection | `.env` file written by deploy step | Docker Compose reads `.env` for variable substitution in labels |
| CI structure | Dedicated step with clear comments | App can find and modify env logic, add staging |
| Walkthrough scope | Infra-ready, CI/CD only, Go | Matches target: app devs with infra already set up |

**Alternatives considered:**
- **Multiple traefik_host prompts (dev/prod)**: Rejected—more scaffold prompts; convention is simpler
- **Compose override files per env**: Rejected—more files; `.env` + single compose is sufficient
- **Infra injects at deploy**: Rejected for template—template must be self-contained; CI in template handles it

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Existing scaffolded projects use traefik_host | Document migration: re-scaffold or manually add base_domain, update compose, CI |
| .env not copied by current deploy | Add Ansible task to write `.env` with TRAEFIK_HOST before `docker compose up` |
| Docker Compose env sub in labels | Verify `${TRAEFIK_HOST}` works in labels; use `env_file` or shell env when running compose |

## Migration Plan

- **New scaffolds**: Get `base_domain` instead of `traefik_host`; CI and compose updated
- **Existing projects**: Re-scaffold with cruft update, or manually: add `base_domain` to cookiecutter context, change compose to `${TRAEFIK_HOST}`, update CI
- **Rollback**: Revert template changes; existing deploys keep working (compose already on server)

## Open Questions

- None.
