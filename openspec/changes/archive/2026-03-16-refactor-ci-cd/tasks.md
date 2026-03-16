## 1. Committed Deploy Playbook

- [x] 1.1 Add `.github/deploy.yml` to Go template with tasks: create deploy dir, copy compose, write .env (TRAEFIK_HOST, IMAGE_TAG), registry login (when token set), docker compose pull/up, health check (docker compose ps)
- [x] 1.2 Add `.github/deploy.yml` to Node template (same content as Go)
- [x] 1.3 Add `.github/deploy.yml` to Python template (same content as Go)

## 2. docker-compose.yml Changes

- [x] 2.1 Update Go template docker-compose.yml: image tag to `:${IMAGE_TAG:-latest}`
- [x] 2.2 Update Node template docker-compose.yml: image tag to `:${IMAGE_TAG:-latest}`
- [x] 2.3 Update Python template docker-compose.yml: image tag to `:${IMAGE_TAG:-latest}`

## 3. Go Template CI Workflow

- [x] 3.1 Add prepare job with case statement (main/dev/test → env_name, traefik_host, image_tag_prefix); unsupported branch exits 1
- [x] 3.2 Add test job (setup-go@v6, go test ./...); depends on prepare
- [x] 3.3 Refactor build-and-push: add needs prepare+test; upgrade Docker actions (buildx v4, login v4); add metadata-action@v6 for env-scoped tags; upgrade build-push to v7
- [x] 3.4 Refactor deploy job: needs prepare+build-and-push; environment from prepare; uv install ansible; Write SSH key from env secret; Write inventory from env secret; invoke .github/deploy.yml with -e image_tag; DEPLOY_USER default root

## 4. Node Template CI Workflow and pnpm Migration

- [x] 4.1 Add packageManager to package.json; remove package-lock.json; add pnpm-lock.yaml (run pnpm install)
- [x] 4.2 Update Dockerfile: corepack enable pnpm; pnpm-lock.yaml; pnpm install --frozen-lockfile --prod
- [x] 4.3 Add prepare job (same as Go)
- [x] 4.4 Add test job (setup-node@v6, pnpm/action-setup@v4, pnpm install --frozen-lockfile && pnpm test); depends on prepare
- [x] 4.5 Refactor build-and-push (same structure as Go)
- [x] 4.6 Refactor deploy job (same structure as Go)
- [x] 4.7 Update Node README: npm commands to pnpm; document corepack enable

## 5. Python Template CI Workflow

- [x] 5.1 Add prepare job (same as Go)
- [x] 5.2 Add test job (setup-uv@v7, uv pip install -r requirements.txt, pytest || test $? -eq 5); depends on prepare
- [x] 5.3 Refactor build-and-push (same structure as Go)
- [x] 5.4 Refactor deploy job (same structure as Go)

## 6. Workflow Polish

- [x] 6.1 Add concurrency group (deploy-${{ github.ref_name }}, cancel-in-progress: false) to all three workflows
- [x] 6.2 Add job timeouts (prepare 5m, test 10m, build-and-push 15m, deploy 10m) to all three workflows

## 7. Documentation

- [x] 7.1 Add GitHub Environments setup to generated README: create production/dev/test environments; migrate secrets (PROD_SSH_KEY→SSH_KEY per env, etc.); document DEPLOY_USER default
