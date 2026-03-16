import re
import sys

SLUG_RE = re.compile(r"^[a-z][a-z0-9]*(-[a-z0-9]+)*$")

slug = "{{ cookiecutter.project_slug }}"

if not SLUG_RE.match(slug):
    print(
        f"ERROR: Invalid project_slug '{slug}'.\n"
        "       Must be lowercase letters, digits, and hyphens only.\n"
        "       Must start with a letter. No spaces, uppercase, or trailing hyphens.\n"
        "       Examples: my-service, api-v2, backend"
    )
    sys.exit(1)
