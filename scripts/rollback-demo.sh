#!/usr/bin/env bash
# Rollback demo: deploy a bad image, watch Kubernetes keep the old pods, then undo.
set -uo pipefail
echo "=== 1. Healthy state ==="
kubectl rollout status deployment/todo-api --timeout=60s
kubectl get pods -l app=todo-api

echo; echo "=== 2. Push a BROKEN change (image tag that does not exist) ==="
kubectl set image deployment/todo-api todo-api=todo-api:broken
sleep 20
kubectl get pods -l app=todo-api      # new pod shows ErrImagePull/ImagePullBackOff, old pods stay Ready
kubectl rollout status deployment/todo-api --timeout=20s || echo "(rollout stuck, as expected)"

echo; echo "=== 3. Roll back ==="
kubectl rollout undo deployment/todo-api
kubectl rollout status deployment/todo-api --timeout=120s
kubectl get pods -l app=todo-api
kubectl rollout history deployment/todo-api
echo "Recovered."
