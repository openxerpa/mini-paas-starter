## 1. Go template

- [x] 1.1 Replace `base_domain` with `base_domain_dev`, `base_domain_test`, `base_domain_prod` in cookiecutter.json
- [x] 1.2 Update ci-cd.yml: add test branch to triggers; env mapping main→prod, dev→dev, test→test; use per-env base domain for TRAEFIK_HOST
- [x] 1.3 Update .cruft.json (base_domain → base_domain_dev, base_domain_test, base_domain_prod)

## 2. Node template

- [x] 2.1 Replace `base_domain` with `base_domain_dev`, `base_domain_test`, `base_domain_prod` in cookiecutter.json
- [x] 2.2 Update ci-cd.yml: add test branch; use per-env base domain
- [x] 2.3 Update .cruft.json

## 3. Python template

- [x] 3.1 Replace `base_domain` with `base_domain_dev`, `base_domain_test`, `base_domain_prod` in cookiecutter.json
- [x] 3.2 Update ci-cd.yml: add test branch; use per-env base domain
- [x] 3.3 Update .cruft.json

## 4. Documentation

- [x] 4.1 Update docs/sample-app-cicd-walkthrough.md: per-env base domains (base_domain_dev, base_domain_test, base_domain_prod), test branch, example test: a.com prod: c.com
