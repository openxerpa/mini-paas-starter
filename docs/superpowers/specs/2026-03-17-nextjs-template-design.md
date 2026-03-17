# Next.js Template Design

## Context

The mini-paas-starter project provides cookiecutter templates for services (node-service, python-service, go-service). Each template includes Docker, CI/CD, and deployment workflows aligned with the PaaS conventions. A new Next.js template is needed for full-stack React applications.

## Requirements (from user)

1. **Standalone mode** — Next.js `output: 'standalone'` for minimal production bundle
2. **Dockerfile** — Multi-stage build
3. **.dockerignore** — Exclude unnecessary files from build context
4. **Non-root** — Container runs as non-root user (distroless `:nonroot`)

## Design Decisions

### Approach: Independent `nextjs-service` template

Create `templates/nextjs-service/` alongside existing templates. Mirrors the one-technology-per-template pattern. Next.js build and runtime differ significantly from plain Node; a dedicated template keeps concerns separated and is easier to maintain.

### package.json scripts

Required scripts: `dev` (next dev), `build` (next build), `start` (node server.js for standalone), `test` (default `echo 'No tests yet'` for consistency with node-service; Vitest optional). CI expects `pnpm test` to exist and pass.

### Tech Stack

| Choice | Value |
|--------|-------|
| Router | App Router (`app/`) |
| Language | TypeScript |
| Styling | Tailwind CSS |
| Package manager | pnpm (consistent with node-service) |
| Node version | 24 (matches node-service) |

### Standalone Output

- `next.config.ts`: `output: 'standalone'`
- Build produces `.next/standalone` with traced dependencies
- Static assets (`.next/static`, `public`) must be copied separately into the runtime image

### Dockerfile (Multi-Stage)

**Stage 1 — deps:** Install dependencies only
- Base: `node:24-alpine`
- Copy `package.json`, `pnpm-lock.yaml`
- `pnpm install --frozen-lockfile`
- Caches dependency layer for faster rebuilds

**Stage 2 — builder:** Build Next.js app
- Copy deps from stage 1
- Copy source
- `NEXT_TELEMETRY_DISABLED=1 pnpm build`
- Output: `.next/standalone`, `.next/static`

**Stage 3 — runner:** Production runtime
- Base: `gcr.io/distroless/nodejs24-debian13:nonroot`
- Copy `.next/standalone/` → `/app` (includes `server.js`, minimal `node_modules`)
- Copy `.next/static` → `/app/.next/static`
- Copy `public/` → `/app/public`
- `WORKDIR /app`, `CMD ["node", "server.js"]`
- `EXPOSE {{ cookiecutter.service_port }}`

### .dockerignore

Exclude from build context to speed builds and reduce image size:

```
node_modules
.next
.git
.gitignore
README.md
.env
.env.*
!.env.example
*.md
Dockerfile
.dockerignore
.github
```

### CI/CD and Deploy

Reuse node-service workflow structure:

- **prepare** — Resolve env (main→prod, dev→dev, test→test), traefik_host, image_tag_prefix
- **test** — `pnpm install --frozen-lockfile && pnpm build && pnpm test` (requires `package.json` to define a `test` script, e.g. `"test": "echo 'No tests yet'"` like node-service)
- **build-and-push** — Docker buildx, push to registry
- **deploy** — Tailscale, Ansible, same playbook pattern

Workflows: `ci-cd.yml`, `emergency-deploy.yml`, `deploy.yml`. Use `PROD_TAILSCALE_IP`, `DEV_TAILSCALE_IP`, `TEST_TAILSCALE_IP` and corresponding `*_SSH_KEY` (per existing rename-server-ip design).

### pre_gen_project.py

Validates `project_slug` (same regex and error message as node-service). Ensures slug is lowercase, alphanumeric with hyphens, starts with a letter.

### cookiecutter.json

Same variables as node-service:

- `project_name`, `project_slug`, `description`
- `github_org`, `service_type`, `service_port`
- `docker_registry`, `base_domain_dev`, `base_domain_test`, `base_domain_prod`
- `memory_limit`

### docker-compose.yml

Follows the node-service pattern: `image` + `build`, `PORT` env, Traefik labels for `service_type == "external"`, `memory_limit`, `service_type` conditional (external vs internal). Same structure as node-service.

### deploy.yml

Ansible playbook at `.github/deploy.yml`. Reused from node-service pattern (create deploy dir, copy compose, write .env, registry login, pull and start). Not Next.js-specific.

### .cruft.json

Follows node-service pattern: `template` URL, `directory`, `context` with cookiecutter vars.

### Project Structure

```
templates/nextjs-service/
├── cookiecutter.json
├── hooks/
│   └── pre_gen_project.py
└── {{cookiecutter.project_slug}}/
    ├── app/
    │   ├── layout.tsx
    │   ├── page.tsx
    │   └── globals.css
    ├── public/
    ├── .dockerignore
    ├── .env.example
    ├── .gitignore
    ├── .cruft.json
    ├── docker-compose.yml
    ├── Dockerfile
    ├── next.config.ts
    ├── package.json
    ├── pnpm-lock.yaml
    ├── postcss.config.mjs
    ├── tailwind.config.ts
    ├── tsconfig.json
    ├── README.md
    └── .github/
        ├── workflows/
        │   ├── ci-cd.yml
        │   └── emergency-deploy.yml
        └── deploy.yml
```

### README

- Local dev: `corepack enable pnpm`, `pnpm install`, `docker compose up`
- Deployment: push to main/dev/test
- Repo-level secrets table (same as node-service)
- Emergency deploy workflow
- Environment variables (PORT)
- Internal service note (if `service_type == "internal"`)

### .env.example

`PORT={{ cookiecutter.service_port }}` (same as node-service).

### Environment

- `PORT` — HTTP server port (default `{{ cookiecutter.service_port }}`)
- Next.js standalone listens on `process.env.PORT` or 3000

## Implementation Notes

- Use `create-next-app` or manual setup to generate initial Next.js app files, then adapt for cookiecutter
- Ensure `standalone/server.js` path is correct; Next.js 14+ places it at `.next/standalone/server.js` for App Router
- Verify distroless nodejs image includes required Node APIs for Next.js (known risk; test build and run before finalizing)
- **Verification:** Run full build, run container, confirm app responds on expected port
- Update project root README to list nextjs-service if it documents available templates

## Out of Scope

- Pages Router (user chose App Router)
- JavaScript (user chose TypeScript)
- No Tailwind (user chose Tailwind)
- Custom shared workflow fragments (chosen approach: copy and adapt)
