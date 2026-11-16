#!/usr/bin/env bash
# Smoke-test the API. Usage: ./scripts/test-endpoints.sh [BASE_URL]
# Minikube:  ./scripts/test-endpoints.sh "$(minikube service todo-api --url)"
set -euo pipefail
BASE_URL="${1:-http://localhost:8080}"
BODY="$(mktemp)"
trap 'rm -f "$BODY"' EXIT

check() { # name expected_code curl-args...
  local name="$1" expected="$2"; shift 2
  local code
  code="$(curl -s -o "$BODY" -w '%{http_code}' "$@")"
  if [ "$code" = "$expected" ]; then
    echo "PASS  $name -> $code  $(head -c 120 "$BODY")"
  else
    echo "FAIL  $name -> got $code, expected $expected"; cat "$BODY"; exit 1
  fi
}

echo "Testing $BASE_URL"
check "status (/)"          200 "$BASE_URL/"
check "health"              200 "$BASE_URL/health"
check "liveness"            200 "$BASE_URL/health/liveness"
check "readiness"           200 "$BASE_URL/health/readiness"
check "list todos"          200 "$BASE_URL/todos"
check "get todo 1"          200 "$BASE_URL/todos/1"
check "unknown todo"        404 "$BASE_URL/todos/9999"
check "create todo"         201 -X POST -H 'Content-Type: application/json' -d '{"title":"Demo from script"}' "$BASE_URL/todos"
check "reject blank title"  400 -X POST -H 'Content-Type: application/json' -d '{"title":""}' "$BASE_URL/todos"
echo "All checks passed."
