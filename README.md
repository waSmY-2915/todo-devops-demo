# Todo API - CI/CD Pipeline & Kubernetes Deployment

Spring Boot (Java 17, Maven) REST API taken through a full DevOps pipeline:
**Git -> Maven -> Jenkins / GitHub Actions -> Docker -> Ansible -> Kubernetes (scaling, probes, ConfigMap, rollback)**

## Endpoints
| Method | Path | Description |
|---|---|---|
| GET | `/` | App status (service, env, version, pod name) |
| GET | `/todos` | List todos |
| GET | `/todos/{id}` | Get one todo (404 if missing) |
| POST | `/todos` | Add todo, body `{"title":"..."}` -> 201 (400 if blank) |
| GET | `/health` | Health (also `/health/liveness`, `/health/readiness` for Kubernetes) |

Data is in memory (per instance, no database).

## Run locally
```bash
make test            # unit tests
make build           # target/todo-api.jar
make run             # http://localhost:8080
make smoke           # curl-based endpoint checks
```

## Docker
```bash
make docker-build
make docker-run
```

## Kubernetes (minikube)
```bash
minikube start
make docker-build
make minikube-load
make deploy                                   # 3 replicas + Service + ConfigMap
make status
make smoke URL=$(minikube service todo-api --url)
make scale REPLICAS=5                         # then: make scale REPLICAS=3
make rollback                                 # bad image -> kubectl rollout undo
```
(kind: `kind create cluster` and `kind load docker-image todo-api:1.0.0`.)

## Ansible (Ubuntu/WSL/VM with systemd)
```bash
make build
make ansible          # installs Java, copies jar, creates systemd service (role: todo_app)
curl localhost:8080/health
```
Uses a variable (`app_port`), handlers (restart only when jar/unit changes) and a role.
Remote host: edit `ansible/inventory`.

## Jenkins
1. Manage Jenkins -> Tools: add Maven `Maven3` and JDK `JDK17`.
2. New Item -> Pipeline -> "Pipeline script from SCM" -> Git -> your repo URL, branch `main`, script path `Jenkinsfile`.
3. Trigger = SCM polling every minute (already in the Jenkinsfile). Push a change; the build starts by itself.
4. Stages: Checkout -> Test -> Build -> Archive jar -> Docker build tagged `<build#>-<git sha>`.

## GitHub Actions
`.github/workflows/ci.yml` builds, tests and uploads the jar on every push / PR, then builds the Docker image tagged with the commit SHA.

## Git: branches, merges, pull requests
Fastest way (creates `main` + 3 feature branches, merge commits, pushes):
```bash
# create an EMPTY repo on GitHub first, then in this folder:
chmod +x scripts/*.sh
./scripts/git-workflow.sh https://github.com/<you>/<repo>.git          # local --no-ff merges
./scripts/git-workflow.sh https://github.com/<you>/<repo>.git pr       # real PRs (needs: gh auth login)
```
Manual version:
```bash
git init -b main && git add . && git commit -m "chore: initial commit"
git remote add origin <url> && git push -u origin main
git checkout -b feature/hello-endpoint
# ...change something...
git commit -am "feat: ..." && git push -u origin feature/hello-endpoint
# open a Pull Request on GitHub (base: main) -> Merge pull request
git checkout main && git pull
git log --oneline --graph --all        # screenshot this for the report
```
Add your course coordinator under repo Settings -> Collaborators, and put the repo URL in `repo_link.txt`.

## Enhancements implemented
- CI: automated tests stage + build-number/commit-SHA image versioning + GitHub Actions alongside Jenkins
- Deployment: liveness/readiness probes, ConfigMap-driven settings, rollback demo, multi-stage Dockerfile, health endpoint

See `docs/REPORT_CHECKLIST.md` for the screenshots to capture.

## Resume lines
- **Todo API - CI/CD Pipeline & Kubernetes Deployment** | Java 17, Spring Boot, Git, Jenkins, Docker, Ansible, Kubernetes
- Built a REST API (todo CRUD with health endpoints) and automated build + test with Jenkins on every Git push, plus GitHub Actions CI; tagged images by build number and commit SHA.
- Containerized with a multi-stage Dockerfile and deployed on Kubernetes (3 replicas, Service, ConfigMap, liveness/readiness probes) with scaling and rollback demos; automated server setup with an Ansible role, variables and handlers.
