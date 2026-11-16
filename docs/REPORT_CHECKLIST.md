# Report screenshot checklist

## Component 1 (Git + Maven + Jenkins)
- [ ] `git log --oneline --graph --all` showing branches and merge commits
- [ ] Jenkins job configuration (SCM, trigger, build steps)
- [ ] Successful build console output
- [ ] Archived artifact `todo-api.jar`
- [ ] CI enhancement: Test stage passing / image tag `<build#>-<sha>` / GitHub Actions run

## Component 2 (Ansible + Docker + Kubernetes)
- [ ] `ansible-playbook` command and result
- [ ] Dockerfile + successful `docker build`
- [ ] `kubectl get pods` before and after scaling (3 -> 5 -> 3)
- [ ] `kubectl get svc`
- [ ] curl response from the service (`make smoke`)
- [ ] Enhancement: probes in Deployment YAML, ConfigMap applied, rollback output

## Also submit
- [ ] Source folder, `repo_link.txt`, repo link pasted in the report, coordinator added as collaborator
