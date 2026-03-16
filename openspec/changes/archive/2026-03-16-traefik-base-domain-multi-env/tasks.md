## 1. Go template

- [x] 1.1 Replace `traefik_host` with `base_domain` in cookiecutter.json
- [x] 1.2 Update docker-compose.yml: Traefik router rule to use `Host(\`${TRAEFIK_HOST}\`)`
- [x] 1.3 Update ci-cd.yml: add env mapping step (main→prod, dev→dev), TRAEFIK_HOST computation, Ansible task to write .env before compose up
- [x] 1.4 Update README: internal service note to reference base_domain instead of traefik_host
- [x] 1.5 Update .cruft.json if present (traefik_host → base_domain)

## 2. Node template

- [x] 2.1 Replace `traefik_host` with `base_domain` in cookiecutter.json
- [x] 2.2 Update docker-compose.yml: Traefik router rule to use `Host(\`${TRAEFIK_HOST}\`)`
- [x] 2.3 Update ci-cd.yml: add env mapping step, TRAEFIK_HOST computation, Ansible task to write .env
- [x] 2.4 Update README: internal service note to reference base_domain
- [x] 2.5 Update .cruft.json if present

## 3. Python template

- [x] 3.1 Replace `traefik_host` with `base_domain` in cookiecutter.json
- [x] 3.2 Update docker-compose.yml: Traefik router rule to use `Host(\`${TRAEFIK_HOST}\`)`
- [x] 3.3 Update ci-cd.yml: add env mapping step, TRAEFIK_HOST computation, Ansible task to write .env
- [x] 3.4 Update README: internal service note to reference base_domain
- [x] 3.5 Update .cruft.json if present

## 4. Documentation

- [x] 4.1 Create docs/sample-app-cicd-walkthrough.md with scaffold → deploy steps (Go example, CI/CD path, infra note, troubleshooting)
