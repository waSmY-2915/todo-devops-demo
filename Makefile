.RECIPEPREFIX = >
APP      ?= todo-api
VERSION  ?= 1.0.0
IMAGE    ?= $(APP):$(VERSION)
REPLICAS ?= 5
URL      ?= http://localhost:8080

.PHONY: help build test run clean docker-build docker-run minikube-load deploy status scale rollback smoke ansible undeploy

help: ## Show this help
> @grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  %-16s %s\n",$$1,$$2}'

build: ## Compile, test and package target/todo-api.jar
> mvn -B clean package

test: ## Run unit tests
> mvn -B test

run: ## Run the app locally on :8080
> mvn -B spring-boot:run

clean: ## Remove build output
> mvn -B clean

docker-build: ## Build the Docker image
> docker build -t $(IMAGE) .

docker-run: ## Run the image locally on :8080
> docker run --rm -p 8080:8080 $(IMAGE)

minikube-load: ## Load the image into minikube (use `kind load docker-image` for kind)
> minikube image load $(IMAGE)

deploy: ## Apply ConfigMap, Deployment and Service
> kubectl apply -f k8s/
> kubectl rollout status deployment/$(APP) --timeout=180s

status: ## Show pods and service
> kubectl get pods,svc -l app=$(APP)

scale: ## Scale (make scale REPLICAS=5)
> ./scripts/scale.sh $(REPLICAS)

rollback: ## Run the rollback demo
> ./scripts/rollback-demo.sh

smoke: ## Smoke-test endpoints (make smoke URL=...)
> ./scripts/test-endpoints.sh $(URL)

ansible: ## Run the Ansible playbook (needs `make build` first)
> cd ansible && ansible-playbook -i inventory playbook.yml --ask-become-pass

undeploy: ## Delete the Kubernetes resources
> kubectl delete -f k8s/ --ignore-not-found
