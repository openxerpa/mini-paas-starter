#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Temp dir for all cruft create output
TMPDIR="${TMPDIR:-/tmp}"
TEST_DIR="${TMPDIR}/cruft-test-$$"
mkdir -p "$TEST_DIR"

# Cleanup on exit: undo marker commits (update tests), remove temp dir (unless KEEP_TEST_OUTPUT=1)
COMMITS_TO_UNDO=0
cleanup_marker() {
  [ "$COMMITS_TO_UNDO" -gt 0 ] && (cd "$REPO_ROOT" && git reset --hard HEAD~$COMMITS_TO_UNDO)
}
cleanup_temp() {
  [ -z "${KEEP_TEST_OUTPUT:-}" ] && rm -rf "$TEST_DIR"
}
trap 'cleanup_marker; cleanup_temp' EXIT

# Prerequisites
if ! command -v cruft &>/dev/null; then
  echo "ERROR: cruft is not installed. Install with: pip install cruft"
  exit 1
fi

# Update tests use git reset --hard; require clean working tree
if ! (git diff --quiet && git diff --cached --quiet); then
  echo "ERROR: Run with a clean working tree (update tests modify and reset git state)"
  exit 1
fi

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
  cruft create "file://$REPO_ROOT" --directory "templates/$name" --no-input --output-dir="$out_dir"
  proj="$out_dir/my-service"
  [ ! -d "$proj" ] && { echo "FAIL: $name: my-service dir not found"; exit 1; }
  for f in ${REQUIRED_FILES[$name]}; do
    [ ! -f "$proj/$f" ] && { echo "FAIL: $name: missing $f"; exit 1; }
  done
  echo "  OK: $name"
done

echo "=== Update tests ==="
for name in "${TEMPLATES[@]}"; do
  echo "Testing update: $name"
  out_dir="$TEST_DIR/$name"
  proj="$out_dir/my-service"
  cd "$proj"
  rm -f .cruft.json
  cruft link "file://$REPO_ROOT" --directory "templates/$name" --no-input
  MARKER_PATH="templates/${name}/{{cookiecutter.project_slug}}/.cruft-test-marker"
  echo "cruft-update-test" > "$REPO_ROOT/$MARKER_PATH"
  (cd "$REPO_ROOT" && git add "$MARKER_PATH" && git commit -m "temp: cruft test marker")
  COMMITS_TO_UNDO=$((COMMITS_TO_UNDO + 1))
  cruft update --skip-apply-ask
  [ ! -f "$proj/.cruft-test-marker" ] && { echo "FAIL: $name: marker not found after update"; exit 1; }
  cd "$REPO_ROOT"
  echo "  OK: $name"
done

echo "=== All tests passed ==="
