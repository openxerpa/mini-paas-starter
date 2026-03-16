## ADDED Requirements

### Requirement: Deploy playbook uses shell for commands with operators

The deploy playbook SHALL use `ansible.builtin.shell` (not `ansible.builtin.command`) for tasks whose command includes shell operators such as `&&`, `|`, or `;`. The `command` module does not invoke a shell and passes arguments literally, causing failures for commands like `docker compose pull && docker compose up -d`.

#### Scenario: Docker compose pull and up succeeds

- **WHEN** the deploy playbook runs the docker compose task
- **THEN** the task uses `ansible.builtin.shell`
- **AND** the command `docker compose pull && docker compose up -d` executes correctly
- **AND** the playbook completes without "unknown shorthand flag" or argument parsing errors
