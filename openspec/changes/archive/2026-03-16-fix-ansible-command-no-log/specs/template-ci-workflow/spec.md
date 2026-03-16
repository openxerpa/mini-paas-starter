## ADDED Requirements

### Requirement: Deploy playbook uses valid Ansible task structure

The inline deploy playbook SHALL use valid Ansible syntax. Task-level directives (e.g., `no_log`, `when`) MUST be placed at the task level, not nested under the module as parameters. Passing unsupported parameters to modules causes playbook failure.

#### Scenario: Docker login task suppresses credential output

- **WHEN** the deploy playbook runs the docker login task
- **THEN** the task uses `no_log: true` at task level
- **AND** the playbook succeeds without "Unsupported parameters" errors
- **AND** credentials are not logged
