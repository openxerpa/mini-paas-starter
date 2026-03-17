## 1. Emergency deploy workflow (Go template)

- [x] 1.1 Add `.github/workflows/emergency-deploy.yml` to go-service template with `workflow_dispatch` and inputs `image_tag` (required string), `target_env` (required string; values: production, dev, test, or dev-&lt;username&gt; e.g. dev-alice)
- [x] 1.2 Add prepare job that maps `target_env` to `traefik_host` and `deploy_dir` per routing convention: production→slug.base_domain_prod + /opt/apps/slug; dev→slug.dev.base_domain_dev; test→slug.test.base_domain_test; dev-*→slug-username.dev.base_domain_dev + /opt/apps/slug-dev-username
- [x] 1.3 Add deploy job: checkout, Tailscale, uv+Ansible, SSH key, inventory from SERVER_IP, invoke .github/deploy.yml with traefik_host, image_tag, deploy_dir from prepare; use `environment: ${{ inputs.target_env }}`

## 2. Emergency deploy workflow (Node template)

- [x] 2.1 Add `.github/workflows/emergency-deploy.yml` to node-service template (same structure as Go)
- [x] 2.2 Ensure cookiecutter variables (project_slug, base_domain_*) are used correctly

## 3. Emergency deploy workflow (Python template)

- [x] 3.1 Add `.github/workflows/emergency-deploy.yml` to python-service template (same structure as Go)

## 4. Documentation

- [x] 4.1 Add "Emergency deploy" section to README in each template: when to use, how to trigger, inputs (image_tag, target_env including dev-&lt;username&gt;), routing convention {app}.{env}.domain.com, note that image must already exist in registry
