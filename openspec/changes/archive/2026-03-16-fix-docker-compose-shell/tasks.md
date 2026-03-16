## 1. Fix template CI workflows

- [x] 1.1 Replace `ansible.builtin.command` with `ansible.builtin.shell` for docker compose task in go-service template
- [x] 1.2 Replace `ansible.builtin.command` with `ansible.builtin.shell` for docker compose task in node-service template
- [x] 1.3 Replace `ansible.builtin.command` with `ansible.builtin.shell` for docker compose task in python-service template

## 2. Fix infra Ansible playbooks

- [x] 2.1 Replace `ansible.builtin.command` with `ansible.builtin.shell` in `infra/ansible/playbooks/deploy-app.yml`
- [x] 2.2 Replace `ansible.builtin.command` with `ansible.builtin.shell` in `infra/ansible/playbooks/traefik.yml`
