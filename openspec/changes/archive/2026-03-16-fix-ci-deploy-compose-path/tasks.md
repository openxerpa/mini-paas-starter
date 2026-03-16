## 1. Fix inline deploy playbook (all templates)

- [x] 1.1 Add `compose_src` to vars in the inline playbook (go-service, node-service, python-service)
- [x] 1.2 Change copy task from `src: docker-compose.yml` to `src: "{{ compose_src }}"`
- [x] 1.3 Add `-e compose_src=$GITHUB_WORKSPACE/docker-compose.yml` to the ansible-playbook command in Run deploy step
