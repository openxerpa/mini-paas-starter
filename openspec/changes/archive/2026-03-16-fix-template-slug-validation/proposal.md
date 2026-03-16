## Why

Cookiecutter templates allow users to override `project_slug` with arbitrary values (e.g., "GO demo" instead of "go-demo"). This produces broken `go.mod` paths, invalid Traefik router labels, and malformed Docker service names. There are no pre-generation hooks to validate or normalize the slug.

## What Changes

- Add a `pre_gen_project.py` hook to all three service templates (go, node, python) that validates `project_slug` is a proper slug (lowercase, hyphens, no spaces) and aborts generation with a clear error if not.
- Alternatively, auto-normalize the slug in the hook so generation always succeeds with a valid value.

## Capabilities

### New Capabilities
- `template-slug-validation`: Pre-generation hook that enforces slug format for `project_slug` across all cookiecutter service templates.

### Modified Capabilities

_(none)_

## Impact

- **Templates affected**: `templates/go-service/`, `templates/node-service/`, `templates/python-service/`
- **New files**: `hooks/pre_gen_project.py` in each template directory
- **No breaking changes**: Existing correctly-generated projects are unaffected. Users who previously entered non-slug values will now get a validation error or auto-correction.
