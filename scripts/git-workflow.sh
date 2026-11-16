#!/usr/bin/env bash
# Builds a realistic Git history: main + 3 feature branches merged back (merge commits).
#
# Usage:
#   ./scripts/git-workflow.sh <repo-url>          # merges locally with --no-ff, pushes everything
#   ./scripts/git-workflow.sh <repo-url> pr       # real Pull Requests via GitHub CLI (gh auth login first)
#
# Run it ONCE from the repo root in a fresh folder (no existing .git history).
set -euo pipefail
REPO_URL="${1:-}"
MODE="${2:-local}"

[ -d .git ] || git init -b main
git checkout -B main >/dev/null 2>&1 || true

if [ -n "$REPO_URL" ] && ! git remote | grep -q '^origin$'; then
  git remote add origin "$REPO_URL"
fi

git add README.md .gitignore .dockerignore Makefile repo_link.txt docs
git commit -m "chore: initial project skeleton" || true
if [ -n "$REPO_URL" ]; then git push -u origin main; fi

feature() { # branch commit-message paths...
  local branch="$1" msg="$2"; shift 2
  git checkout -b "$branch" main
  git add "$@"
  git commit -m "$msg"
  if [ "$MODE" = "pr" ]; then
    git push -u origin "$branch"
    gh pr create --base main --head "$branch" --title "$msg" --body "Adds: $*"
    gh pr merge "$branch" --merge          # branch is kept so it shows in the repo
    git checkout main && git pull origin main
  else
    git checkout main
    git merge --no-ff "$branch" -m "Merge branch '$branch'"
    if [ -n "$REPO_URL" ]; then git push origin main "$branch"; fi
  fi
}

feature feature/todo-api      "feat: add Todo REST API with unit tests"                         pom.xml src
feature feature/ci-pipeline   "ci: add Jenkinsfile, GitHub Actions workflow and Dockerfile"     Jenkinsfile .github Dockerfile
feature feature/k8s-ansible   "feat: add Kubernetes manifests, Ansible role and helper scripts" k8s ansible scripts

echo; git log --oneline --graph --all
