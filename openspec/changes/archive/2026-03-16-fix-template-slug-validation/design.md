## Context

All three cookiecutter service templates (go, node, python) derive `project_slug` from `project_name` via Jinja filters in `cookiecutter.json`:

```
"project_slug": "{{ cookiecutter.project_name|lower|replace(' ', '-') }}"
```

However, cookiecutter prompts users for every field and allows overriding the computed default. A user can type "GO demo" as the slug value, producing broken Go module paths, invalid Traefik labels, and non-standard Docker names. No pre-generation hooks exist today.

## Goals / Non-Goals

**Goals:**
- Ensure `project_slug` is always a valid slug (lowercase alphanumeric + hyphens, no leading/trailing hyphens) after project generation.
- Apply validation consistently across all three service templates.
- Provide a clear error message when the user enters an invalid slug.

**Non-Goals:**
- Auto-correcting arbitrary input silently (user should know what slug was used).
- Changing the cookiecutter prompting behavior or removing the `project_slug` field.
- Validating other cookiecutter variables beyond `project_slug`.

## Decisions

### 1. Pre-generation hook with fail-fast validation

**Choice**: Add a `hooks/pre_gen_project.py` to each template that validates `project_slug` against a regex pattern and aborts with `sys.exit(1)` if invalid.

**Alternatives considered**:
- *Auto-normalize in hook*: Silently fix the slug. Rejected because the user wouldn't know the actual directory/module name, leading to confusion.
- *Post-generation hook*: Rename files after generation. More complex and error-prone with nested paths.
- *Remove `project_slug` from prompts*: Mark as `_project_slug` (private). Removes user control over the slug entirely.

**Rationale**: Fail-fast with a clear error is the simplest, most transparent approach. The user retries with a valid slug. The hook is a single Python file with no dependencies.

### 2. Shared hook content, duplicated per template

**Choice**: Each template gets its own `hooks/pre_gen_project.py` with identical content.

**Rationale**: Cookiecutter hooks must live inside each template's `hooks/` directory. There's no built-in mechanism for shared hooks. With only ~15 lines of code, duplication is acceptable and keeps templates self-contained.

### 3. Slug validation regex

**Choice**: `^[a-z][a-z0-9]*(-[a-z0-9]+)*$`

This enforces:
- Starts with a lowercase letter
- Contains only lowercase letters, digits, and hyphens
- No consecutive hyphens, no leading/trailing hyphens
- Minimum 1 character

## Risks / Trade-offs

- **[Strictness may block valid names]** → The regex rejects slugs starting with a digit. This is intentional since Go module names and DNS labels require a leading letter.
- **[Duplication across templates]** → If the hook logic changes, all three copies must be updated. Acceptable given the small size and low change frequency.
