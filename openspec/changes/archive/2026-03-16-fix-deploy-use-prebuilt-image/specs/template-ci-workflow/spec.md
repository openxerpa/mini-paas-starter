## ADDED Requirements

### Requirement: Deploy uses pre-built registry image

The docker-compose.yml SHALL include an `image:` directive for the app service pointing to the registry image built and pushed by CI. This allows the deploy step to `docker compose pull` the image and run it without attempting a local build. The server receives only the compose file, not the Dockerfile or source.

#### Scenario: Deploy pulls and runs pre-built image

- **WHEN** the deploy job runs `docker compose pull && docker compose up -d` on the server
- **THEN** the compose file references the registry image (e.g., `ghcr.io/org/slug:latest`)
- **AND** `pull` retrieves the image built by the build-and-push job
- **AND** `up -d` starts the container without attempting a local build
- **AND** the deploy completes without "Dockerfile: no such file or directory" errors
