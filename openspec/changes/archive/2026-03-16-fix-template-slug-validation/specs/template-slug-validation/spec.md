## ADDED Requirements

### Requirement: Slug validation on project generation
Each cookiecutter service template (go-service, node-service, python-service) SHALL include a `hooks/pre_gen_project.py` that validates `{{ cookiecutter.project_slug }}` before generating any files.

The slug MUST match the pattern `^[a-z][a-z0-9]*(-[a-z0-9]+)*$` — lowercase letters, digits, and single hyphens only, starting with a letter.

#### Scenario: Valid slug accepted
- **WHEN** the user runs cookiecutter with `project_slug` set to `my-service`
- **THEN** generation proceeds without error

#### Scenario: Valid slug with digits accepted
- **WHEN** the user runs cookiecutter with `project_slug` set to `api-v2`
- **THEN** generation proceeds without error

#### Scenario: Slug with spaces rejected
- **WHEN** the user runs cookiecutter with `project_slug` set to `GO demo`
- **THEN** generation aborts with exit code 1 and an error message containing the invalid slug value and the expected format

#### Scenario: Slug with uppercase rejected
- **WHEN** the user runs cookiecutter with `project_slug` set to `MyService`
- **THEN** generation aborts with exit code 1 and an error message containing the invalid slug value and the expected format

#### Scenario: Slug starting with digit rejected
- **WHEN** the user runs cookiecutter with `project_slug` set to `2fast`
- **THEN** generation aborts with exit code 1 and an error message containing the invalid slug value and the expected format

#### Scenario: Slug with trailing hyphen rejected
- **WHEN** the user runs cookiecutter with `project_slug` set to `my-service-`
- **THEN** generation aborts with exit code 1 and an error message containing the invalid slug value and the expected format

### Requirement: Consistent hook across all templates
The `hooks/pre_gen_project.py` file SHALL exist in all three template directories: `templates/go-service/hooks/`, `templates/node-service/hooks/`, and `templates/python-service/hooks/`, with identical validation logic.

#### Scenario: All templates have the hook
- **WHEN** a developer inspects the three template directories
- **THEN** each contains `hooks/pre_gen_project.py` with the same slug validation regex and error message format
