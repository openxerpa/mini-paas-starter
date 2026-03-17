# Cruft Local Testing Design

## Context

The mini-paas-starter repo provides four Cookiecutter templates (go-service, node-service, python-service, nextjs-service). Each template includes `cookiecutter.json`, `pre_gen_project.py` hooks, and a generated `.cruft.json` in the output project. There is no automated way to verify that template changes work correctly before commit or in CI.

## Requirements

1. **Scope** — Test the full cruft configuration: `cookiecutter.json` variables, `pre_gen_project.py` validation, `.cruft.json` in generated projects, and end-to-end flow.
2. **Goals** — Cover (a) `cruft create` scaffolding, (b) `cruft update` merging template changes into existing projects, and (c) CI regression to prevent template breakage.
3. **Trigger** — Make target for local use; same tests run in GitHub Actions on push/PR.

## Design Decisions

### Approach: Single Shell Script + Make + CI

One script (`scripts/test-cruft.sh`) implements all test logic. Makefile and GitHub Actions both invoke it. Keeps behavior identical locally and in CI, and simplifies maintenance.

### Script Responsibilities

1. **Prerequisites** — Check that `cruft` is installed; exit with clear error if not.
2. **Create tests** — For each template, run `cruft create ./templates/<name> --no-input --output-dir=<temp>/<template-name>`, assert success and that key output files exist.
3. **Update tests** — For each template: create a project, `cruft link` to local template, apply a known template change, run `cruft update`, verify the change appears in the project.
4. **Cleanup** — Use a temp directory; delete on success. If `KEEP_TEST_OUTPUT=1`, retain for debugging.

### Local Update Testing Strategy

Generated `.cruft.json` points to GitHub. To test `cruft update` against local (unpushed) changes, we use `cruft link` after create to point the project at the local template path. Then we can modify the template and run `cruft update` to verify the merge.

### Temp Directory

- Default: `$TMPDIR/cruft-test-$$` (or `./.cruft-test-output` if TMPDIR unset).
- Script runs from repo root; templates are `./templates/<name>`.
- All `cruft create` output goes under the temp dir via `--output-dir=<temp>/<template-name>`. This isolates each template's output and avoids polluting the repo root.

### Create Test Assertions

For each template, run `cruft create ./templates/<name> --no-input --output-dir=<temp>/<template-name>`. This puts each template's output in a separate subdir (e.g. `<temp>/go-service/my-service`) so sequential runs don't overwrite each other.

After create:

- Exit code is 0.
- Output directory exists (default slug: `my-service` from "My Service").
- Required files exist (template-specific; see below).

### Update Test Flow

1. Create project from template (using `--output-dir` as above).
2. `cd` into the created project directory.
3. Run `cruft link <REPO_ROOT>/templates/<name>`. Store repo root before any `cd` (e.g. `REPO_ROOT=$(pwd)` at script start).
4. Add a marker file to the template (e.g. `{{cookiecutter.project_slug}}/.cruft-test-marker`).
5. Run `cruft update --skip-apply-ask` (or `-y`) in the project to apply updates non-interactively.
6. Verify marker file exists in project.
7. Remove marker from template (restore template to original state).

**Cleanup on failure:** Use a `trap` to ensure step 7 runs even if step 5 or 6 fails. Store the marker path in a variable; on EXIT (or ERR), remove the marker if it exists. This prevents leaving the template dirty when the test fails.

**Implementation note:** `cruft update --skip-apply-ask` is documented in cruft's GitHub Actions example. Confirm via `cruft update --help` if the flag changes.

### Template-Specific Required Files (Create Assertion)

| Template        | Required files (in `my-service/`)                                      |
|----------------|-------------------------------------------------------------------------|
| go-service     | `go.mod`, `Dockerfile`, `docker-compose.yml`, `.cruft.json`, `.env.example` |
| node-service   | `package.json`, `Dockerfile`, `docker-compose.yml`, `.cruft.json`, `.env.example` |
| python-service | `requirements.txt`, `Dockerfile`, `docker-compose.yml`, `.cruft.json`, `.env.example` |
| nextjs-service | `package.json`, `Dockerfile`, `docker-compose.yml`, `.cruft.json`, `.env.example` |

### pre_gen_project.py Validation (Optional)

A separate test can verify that invalid `project_slug` (e.g. `Invalid_Slug`) causes create to fail. This requires passing custom context; `cruft create` with `--extra-context` or similar. If cruft does not support overriding slug easily, we defer this to a later iteration.

### Error Handling

- Script uses `set -e` (or equivalent) so any command failure stops execution.
- On failure, print which template and phase failed; optionally print last N lines of output.
- Exit code 1 on any failure.

### Test Order

Run all create tests first (for all four templates), then all update tests. This keeps cleanup and failure handling predictable: create tests use temp dirs only; update tests modify the template in place and must restore via trap.

### Makefile

- Target: `test-templates`.
- Action: `./scripts/test-cruft.sh` (script must be executable).
- Repo root has no Makefile today; we add one.

### CI Workflow

- New file: `.github/workflows/test-templates.yml`.
- Triggers: `push` (main, dev, test) and `pull_request` to those branches. Verify branch names against the actual repo before wiring.
- Steps:
  1. Checkout repo.
  2. Install cruft: `pip install cruft` (matches cruft's official GitHub Actions example). Consider pinning version (e.g. `cruft==X.Y.Z`) to avoid surprises from future cruft changes.
  3. Run `./scripts/test-cruft.sh`.

### Script Location and Invocation

- Path: `scripts/test-cruft.sh`.
- Must be executable (`chmod +x`).
- Invoked from repo root: `./scripts/test-cruft.sh`.

## Out of Scope

- Testing `cruft update` against the real GitHub URL (would require pushing first; not useful for local/PR validation).
- Deep validation of generated project behavior (e.g. `go build`, `pnpm install`). That can be added later if needed.

## Summary

| Component              | Location                          |
|------------------------|-----------------------------------|
| Test script            | `scripts/test-cruft.sh`           |
| Makefile               | `Makefile` (repo root)            |
| CI workflow            | `.github/workflows/test-templates.yml` |
