## 1. Add image directive to docker-compose templates

- [x] 1.1 Add `image: {{ cookiecutter.docker_registry }}/{{ cookiecutter.github_org }}/{{ cookiecutter.project_slug }}:latest` to go-service docker-compose.yml
- [x] 1.2 Add `image: {{ cookiecutter.docker_registry }}/{{ cookiecutter.github_org }}/{{ cookiecutter.project_slug }}:latest` to node-service docker-compose.yml
- [x] 1.3 Add `image: {{ cookiecutter.docker_registry }}/{{ cookiecutter.github_org }}/{{ cookiecutter.project_slug }}:latest` to python-service docker-compose.yml
