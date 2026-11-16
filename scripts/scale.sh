#!/usr/bin/env bash
# Scale demo. Usage: ./scripts/scale.sh [REPLICAS]   (default 5)
set -euo pipefail
REPLICAS="${1:-5}"
echo "--- before ---"; kubectl get pods -l app=todo-api
kubectl scale deployment todo-api --replicas="$REPLICAS"
kubectl rollout status deployment/todo-api --timeout=120s
echo "--- after (replicas=$REPLICAS) ---"; kubectl get pods -l app=todo-api
