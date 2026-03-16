# {{ cookiecutter.project_name }}

{{ cookiecutter.description }}

## Local development

```bash
docker compose up
```

## Deployment

Push to `main`; CI/CD builds and deploys automatically.

## Environment variables

| Variable | Description |
|----------|-------------|
| `PORT` | HTTP server port (default: {{ cookiecutter.service_port }}) |

{% if cookiecutter.service_type == "internal" %}
**Note:** This is an internal service. The `traefik_host` prompt value is ignored; other services reach this via `http://{{ cookiecutter.project_slug }}:{{ cookiecutter.service_port }}`.
{% endif %}
