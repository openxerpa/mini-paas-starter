# Cruft Local Testing Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add automated testing for cruft templates (create + update) via a shell script, Makefile target, and GitHub Actions workflow—so template changes can be verified locally and in CI before merge.

**Architecture:** Single script `scripts/test-cruft.sh` implements create and update tests for all four templates (go, node, python, nextjs). Makefile and CI both invoke it. Create tests run first (isolated via `--output-dir`); update tests use `cruft link` to point at local template, add a marker file, run `cruft update --skip-apply-ask`, verify, and restore via trap.

**Tech Stack:** Bash, cruft, Make, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-03-17-cruft-local-testing-design.md`

---

## File Structure

| Path | Responsibility |
|------|----------------|
| `scripts/test-cruft.sh` | All test logic: prereq check, create tests, update tests, cleanup |
| `Makefile` | Target `test-templates` invokes script |
| `.github/workflows/test-templates.yml` | CI: install cruft, run script on push/PR to main |

---

## Chunk 1: Test Script

### Task 1: Create scripts/test-cruft.sh

**Files:**
- Create: `scripts/test-cruft.sh`

- [ ] **Step 1: Create scripts directory and script skeleton**

```bash
mkdir -p scripts
```

Create `scripts/test-cruft.sh` with shebang, set -e, REPO_ROOT, and temp dir:

```bash
#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Temp dir for all cruft create output
TMPDIR="${TMPDIR:-/tmp}"
TEST_DIR="${TMPDIR}/cruft-test-$$"
mkdir -p "$TEST_DIR"

# Cleanup on exit: remove marker (update tests), remove temp dir (unless KEEP_TEST_OUTPUT=1)
MARKER_PATH=""
cleanup_marker() {
  [ -n "$MARKER_PATH" ] && [ -f "$REPO_ROOT/$MARKER_PATH" ] && rm -f "$REPO_ROOT/$MARKER_PATH"
}
cleanup_temp() {
  [ -z "${KEEP_TEST_OUTPUT:-}" ] && rm -rf "$TEST_DIR"
}
trap 'cleanup_marker; cleanup_temp' EXIT
```

- [ ] **Step 2: Add prerequisites check**

Append to script:

```bash
# Prerequisites
if ! command -v cruft &>/dev/null; then
  echo "ERROR: cruft is not installed. Install with: pip install cruft"
  exit 1
fi
```

- [ ] **Step 3: Add create test loop**

Append (after prereq check):

```bash
# Required files per template (relative to my-service/)
declare -A REQUIRED_FILES
REQUIRED_FILES[go-service]="go.mod Dockerfile docker-compose.yml .cruft.json .env.example"
REQUIRED_FILES[node-service]="package.json Dockerfile docker-compose.yml .cruft.json .env.example"
REQUIRED_FILES[python-service]="requirements.txt Dockerfile docker-compose.yml .cruft.json .env.example"
REQUIRED_FILES[nextjs-service]="package.json Dockerfile docker-compose.yml .cruft.json .env.example"

TEMPLATES=(go-service node-service python-service nextjs-service)

echo "=== Create tests ==="
for name in "${TEMPLATES[@]}"; do
  echo "Testing create: $name"
  out_dir="$TEST_DIR/$name"
  mkdir -p "$out_dir"
  cruft create "$REPO_ROOT/templates/$name" --no-input --output-dir="$out_dir"
  proj="$out_dir/my-service"
  [ ! -d "$proj" ] && { echo "FAIL: $name: my-service dir not found"; exit 1; }
  for f in ${REQUIRED_FILES[$name]}; do
    [ ! -f "$proj/$f" ] && { echo "FAIL: $name: missing $f"; exit 1; }
  done
  echo "  OK: $name"
done
```

- [ ] **Step 4: Add update test loop**

Append:

```bash
echo "=== Update tests ==="
for name in "${TEMPLATES[@]}"; do
  echo "Testing update: $name"
  out_dir="$TEST_DIR/$name"
  proj="$out_dir/my-service"
  cd "$proj"
  cruft link "$REPO_ROOT/templates/$name" --no-input
  # Add marker to template, run update, verify, remove
  MARKER_PATH="templates/${name}/{{cookiecutter.project_slug}}/.cruft-test-marker"
  echo "cruft-update-test" > "$REPO_ROOT/$MARKER_PATH"
  cruft update --skip-apply-ask
  [ ! -f "$proj/.cruft-test-marker" ] && { echo "FAIL: $name: marker not found after update"; exit 1; }
  rm -f "$REPO_ROOT/$MARKER_PATH"
  MARKER_PATH=""
  cd "$REPO_ROOT"
  echo "  OK: $name"
done
```

- [ ] **Step 5: Add success message**

Append at end of script:

```bash
echo "=== All tests passed ==="
```

- [ ] **Step 6: Make executable and run**

From repo root:

```bash
chmod +x scripts/test-cruft.sh
./scripts/test-cruft.sh
```

Expected: All create and update tests pass. Exit 0.

- [ ] **Step 7: Commit**

```bash
git add scripts/test-cruft.sh
git commit -m "feat: add cruft template test script (create + update)"
```

---

## Chunk 2: Makefile and CI

### Task 2: Create Makefile

**Files:**
- Create: `Makefile`

- [ ] **Step 1: Create Makefile**

Create `Makefile` at repo root:

```makefile
.PHONY: test-templates

test-templates:
	./scripts/test-cruft.sh
```

- [ ] **Step 2: Verify**

```bash
make test-templates
```

Expected: Same as running script directly. Exit 0.

- [ ] **Step 3: Commit**

```bash
git add Makefile
git commit -m "feat: add make test-templates target"
```

### Task 3: Create GitHub Actions workflow

**Files:**
- Create: `.github/workflows/test-templates.yml`

- [ ] **Step 1: Create workflow directory and file**

```bash
mkdir -p .github/workflows
```

Create `.github/workflows/test-templates.yml`:

```yaml
name: Test Templates

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test-templates:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v6
        with:
          python-version: "3.13"

      - name: Install cruft
        run: pip install cruft  # Optional: pin with cruft==X.Y.Z for reproducibility

      - name: Run template tests
        run: ./scripts/test-cruft.sh
```

Note: Spec mentioned main, dev, test branches. Repo only has `main`. Use main for now; add dev/test to `branches:` if they exist later.

- [ ] **Step 2: Verify workflow syntax**

```bash
# Optional: use actionlint if available
which actionlint && actionlint .github/workflows/test-templates.yml || true
```

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/test-templates.yml
git commit -m "ci: add test-templates workflow for cruft create/update"
```

---

## Verification Checklist

After implementation:

- [ ] `./scripts/test-cruft.sh` passes locally
- [ ] `make test-templates` passes
- [ ] Push to a branch and open PR; CI job runs and passes
- [ ] `KEEP_TEST_OUTPUT=1 ./scripts/test-cruft.sh` leaves output in `$TMPDIR/cruft-test-<pid>` for inspection
