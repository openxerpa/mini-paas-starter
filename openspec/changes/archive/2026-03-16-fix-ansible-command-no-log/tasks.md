## 1. Fix template CI workflows

- [x] 1.1 Move `no_log` and `when` to task level in go-service template (`templates/go-service/{{cookiecutter.project_slug}}/.github/workflows/ci-cd.yml`)
- [x] 1.2 Move `no_log` and `when` to task level in node-service template (`templates/node-service/{{cookiecutter.project_slug}}/.github/workflows/ci-cd.yml`)
- [x] 1.3 Move `no_log` and `when` to task level in python-service template (`templates/python-service/{{cookiecutter.project_slug}}/.github/workflows/ci-cd.yml`)

## 2. Fix standalone Ansible playbook

- [x] 2.1 Move `no_log` to task level in `infra/ansible/playbooks/deploy-app.yml`
