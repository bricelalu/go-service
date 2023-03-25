SHELL := /bin/bash

run:
	go run main.go

build:
	go build -ldflags "-X main.build=local"

tidy:
	go mod tidy
	go mod vendor
# ==============================================================================
# Building containers

VERSION := 1.0

all: service

service:
	docker build \
		-f zarf/docker/Dockerfile \
		-t service-amd64:$(VERSION) \
		--build-arg BUILD_REF=$(VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.

# ==============================================================================
# Running from within k8s/kind

KIND_CLUSTER := lalu-starter-cluster

kind-up-local:
	kind create cluster \
		--image kindest/node:v1.25.3@sha256:f52781bc0d7a19fb6c405c2af83abfeb311f130707a0e219175677e366cc45d1 \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/kind-config.yaml

kind-down-local:
	kind delete cluster --name $(KIND_CLUSTER)

kind-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide
	kubectl get po -o wide --watch --all-namespace

kind-load:
	kind load docker-image service-amd64:${VERSION} --name ${KIND_CLUSTER}

kind-apply:
	kustomize build zarf/k8s/kind/service-pod | kubectl apply -f -

kind-remove:
	cat zarf/k8s/base/service-pod/base-service.yaml | kubectl delete -f -

kind-logs:
	kubectl logs --namespace=service -l app=service -c service-api

kind-restart:
	kubectl rollout restart deployment service --namespace=service

kind-update: all kind-load kind-restart

kind-update-apply: all kind-load kind-apply