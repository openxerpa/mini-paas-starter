## Why

The deploy step fails with "failed to read dockerfile: open Dockerfile: no such file or directory". The deploy copies only `docker-compose.yml` to the server and runs `docker compose pull && docker compose up -d`. The compose file has `build: .` but no `image:` directive, so `pull` has nothing to pull and `up` tries to build locally—but the Dockerfile and source code are not on the server.

## What Changes

- Add `image:` directive to docker-compose.yml in all service templates (go, node, python)
- Image format: `{{ docker_registry }}/{{ github_org }}/{{ project_slug }}:latest` (matches CI build-and-push)
- Keep `build: .` for local development; when both exist, deploy uses the pre-built image

## Capabilities

### New Capabilities

- None

### Modified Capabilities

- `template-ci-workflow`: Deploy playbook expects docker-compose to reference pre-built registry image so `pull` succeeds and `up` does not attempt local build

## Impact

- **Templates**: docker-compose.yml in go-service, node-service, python-service
- **Behavior**: Deploy pulls pre-built image from registry instead of attempting build on server
- **Local dev**: Unchanged—`docker compose up` still builds from Dockerfile when image not present
