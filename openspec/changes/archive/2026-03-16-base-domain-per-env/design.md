## Context

Templates currently use a single `base_domain`; CI derives TRAEFIK_HOST as `{slug}.{base_domain}` (prod) or `{slug}-dev.{base_domain}` (dev). Teams often need different base domains per environment (e.g. test: `a.com`, prod: `c.com`).

## Goals / Non-Goals

**Goals:**
- Support per-env base domains: `base_domain_dev`, `base_domain_test`, `base_domain_prod`
- CI uses the correct base domain per branch (main → prod, dev → dev, test → test)
- Domain format: prod = `{slug}.{base_domain_prod}`; dev/test = `{slug}-{env}.{base_domain_env}`

**Non-Goals:**
- Arbitrary env names beyond dev/test/prod (app can extend CI)
- Changing internal service behavior

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Env vars | `base_domain_dev`, `base_domain_test`, `base_domain_prod` | Explicit; matches user example (test: a.com, prod: c.com) |
| Branch mapping | main → prod, dev → dev, test → test | Add `test` branch to CI triggers |
| Domain format | prod: `{slug}.{base}`, dev/test: `{slug}-{env}.{base}` | Consistent with current convention |

**Alternatives considered:**
- **Single base_domain with override**: Rejected—less explicit
- **JSON/YAML config for domains**: Rejected—more complex for scaffold

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| More scaffold prompts | Defaults can reuse same domain (e.g. example.com) for all three |
| Existing projects | Migration: add three vars, update CI |

## Migration Plan

- **New scaffolds**: Get three base_domain prompts
- **Existing**: Add `base_domain_dev`, `base_domain_test`, `base_domain_prod`; set each from current `base_domain`; update CI env logic; add `test` branch if needed

## Open Questions

- None.
