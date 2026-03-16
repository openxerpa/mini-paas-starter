### Requirement: Deploy step locates docker-compose.yml correctly

The generated CI workflow SHALL pass the absolute path to `docker-compose.yml` to the Ansible deploy playbook so the copy task can find the file. The playbook runs from `/tmp/`; the file lives in the repo checkout (`$GITHUB_WORKSPACE`).

#### Scenario: Deploy step copies docker-compose.yml

- **WHEN** the deploy job runs and executes the Ansible copy task
- **THEN** the copy task receives `compose_src` set to `$GITHUB_WORKSPACE/docker-compose.yml`
- **AND** the file is found and copied to the deploy directory on the target host
