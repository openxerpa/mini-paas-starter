## Context

The CI workflow has two jobs: (1) build-and-push builds the image and pushes to ghcr.io; (2) deploy copies docker-compose.yml to the server and runs `docker compose pull && docker compose up -d`. The compose file only has `build: .`—no `image:`—so deploy has nothing to pull and attempts a local build, which fails because the server has no Dockerfile or source.

## Goals / Non-Goals

**Goals:**
- Deploy uses the pre-built image from the registry
- Local development continues to work (build from Dockerfile when no image present)

**Non-Goals:**
- Changing the deploy job to copy build context (Dockerfile, source)
- Supporting deploy-time builds

## Decisions

### Add `image:` alongside `build: .`

**Choice:** Add `image: {{ docker_registry }}/{{ github_org }}/{{ project_slug }}:latest` to the app service in docker-compose.yml. Keep `build: .` for local dev.

**Rationale:** Docker Compose uses `image` for pull/run when available; falls back to `build` when the image is not present. So: deploy pulls and runs the image; local dev builds from Dockerfile.

**Image format:** Must match CI build-and-push tags: `{{ docker_registry }}/{{ github_org }}/{{ project_slug }}:latest`. The `github_org` cookiecutter variable should match the GitHub repo owner (org or user).

**Alternatives considered:**
- Separate compose file for deploy: More files, duplication; rejected.
- Deploy copies Dockerfile + source: Heavy, slow; rejected.

### Use `github_org` for image path

**Choice:** Use `{{ cookiecutter.github_org }}` as the registry path segment (between registry and project_slug).

**Rationale:** Matches the convention that CI uses `github.repository_owner` (org or user). Users set `github_org` at generation to their GitHub org; it should align with `repository_owner`.

## Risks / Trade-offs

- **[github_org mismatch]**: If `github_org` ≠ `repository_owner`, pull will fail. Mitigation: Document in README that `github_org` must match the repo owner.
- **Local dev**: Unchanged; `docker compose up` still builds when image is absent.
