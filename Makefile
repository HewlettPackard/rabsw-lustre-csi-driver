# Copyright 2021, 2022 Hewlett Packard Enterprise Development LP
# Other additional copyright holders may be indicated within.
#
# The entirety of this work is licensed under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
#
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Default container tool to use.
#   To use podman:
#   $ DOCKER=podman make docker-build
DOCKER ?= docker

VERSION ?= $(shell sed 1q .version)
IMAGE_TAG_BASE ?= ghcr.io/hewlettpackard/lustre-csi-driver
IMG ?= $(IMAGE_TAG_BASE):$(VERSION)

# Tell Kustomize to deploy the default config, or an overlay.
# To use the 'lustre' overlay:
#   export KUBECONFIG=/my/kubeconfig.file
#   make deploy OVERLAY=lustre


all: build

fmt: ## Run go fmt against code.
	go fmt ./...

vet: ## Run go vet against code.
	go vet ./...

build: fmt vet docker-build
	go build -o bin/lustre-csi-driver

run: fmt vet
	go run ./main.go

docker-build: Dockerfile fmt vet
	# Name the base stages so they are not lost during a cache prune.
	time ${DOCKER} build -t ${IMG} .

push-kind:
	# Push image to Kind environment
	kind load docker-image $(IMG)

deploy_overlay: kustomize ## Deploy controller to the K8s cluster specified in ~/.kube/config.
	cd config/default && $(KUSTOMIZE) edit set image controller=${IMG}
	$(KUSTOMIZE) build config/$(OVERLAY) | kubectl apply -f -

deploy: OVERLAY ?= lustre
deploy: deploy_overlay

deploy-kind: OVERLAY=kind
deploy-kind: deploy_overlay

undeploy_overlay: ## Undeploy controller from the K8s cluster specified in ~/.kube/config.
	$(KUSTOMIZE) build config/$(OVERLAY) | kubectl delete -f -

undeploy: OVERLAY ?= lustre
undeploy: undeploy_overlay

undeploy-kind: OVERLAY=kind
undeploy-kind: undeploy_overlay

KUSTOMIZE = $(shell pwd)/bin/kustomize
kustomize: ## Download kustomize locally if necessary.
	$(call go-get-tool,$(KUSTOMIZE),sigs.k8s.io/kustomize/kustomize/v3@v3.8.7)

# go-get-tool will 'go get' any package $2 and install it to $1.
PROJECT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
define go-get-tool
@[ -f $(1) ] || { \
set -e ;\
TMP_DIR=$$(mktemp -d) ;\
cd $$TMP_DIR ;\
go mod init tmp ;\
echo "Downloading $(2)" ;\
GOBIN=$(PROJECT_DIR)/bin go get $(2) ;\
rm -rf $$TMP_DIR ;\
}
endef
