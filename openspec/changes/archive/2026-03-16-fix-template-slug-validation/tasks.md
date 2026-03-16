## 1. Create pre-generation hook

- [x] 1.1 Create `templates/go-service/hooks/pre_gen_project.py` with slug validation: regex `^[a-z][a-z0-9]*(-[a-z0-9]+)*$`, exit 1 with clear error on mismatch
- [x] 1.2 Copy the same hook to `templates/node-service/hooks/pre_gen_project.py`
- [x] 1.3 Copy the same hook to `templates/python-service/hooks/pre_gen_project.py`

## 2. Verify

- [x] 2.1 Test go-service template with a valid slug (e.g., `my-service`) — generation succeeds
- [x] 2.2 Test go-service template with an invalid slug (e.g., `GO demo`) — generation aborts with error
