ifndef $(GOPATH)
    GOPATH=$(shell go env GOPATH)
    export GOPATH
endif

export KUBECONFIG

# from https://suva.sh/posts/well-documented-makefiles/
.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: manifests_generate
manifests_generate: depend ## Generate YAML manifests to yamls directory
	./build.sh config.jsonnet

.PHONY: manifests_validate
manifests_validate: depend manifests/$(CLOUD)-config.json ## Use kubecfg to validate manifests
	$(GOPATH)/bin/kubecfg $(EXT_VARS) validate config.jsonnet

.PHONY: manifests_validate
jsonnet_fmt: depend ## validate formatting of jsonnet files
	$(GOPATH)/bin/jsonnetfmt --test $(shell find manifests/components/. manifests/main.jsonnet -name "*.jsonnet")

.PHONY: verify
verify: jsonnet_fmt ## verify code and vendor

.PHONY: depend 
depend: $(GOPATH)/bin/kubecfg $(GOPATH)/bin/jsonnet $(GOPATH)/bin/jsonnetfmt $(GOPATH)/bin/gojsontoyaml $(GOPATH)/bin/jb manifests/vendor ## Ensure that dependencies are available. 

$(GOPATH)/bin/kubecfg:
	go get github.com/bitnami/kubecfg

$(GOPATH)/bin/jsonnet:
	go get github.com/google/go-jsonnet/cmd/jsonnet

$(GOPATH)/bin/jsonnetfmt:
	go get github.com/google/go-jsonnet/cmd/jsonnetfmt

$(GOPATH)/bin/jb:
	go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb

$(GOPATH)/bin/gojsontoyaml:
	go get github.com/brancz/gojsontoyaml

manifests/vendor:
	(cd manifests && $(GOPATH)/bin/jb update)