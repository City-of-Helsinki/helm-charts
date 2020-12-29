
#!/usr/bin/env bash

# https://github.com/prometheus-operator/kube-prometheus/blob/master/build.sh
# This script uses arg $1 (name of *.jsonnet file to use) to generate the manifests/*.yaml files.

set -e
set -x
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

# Make sure to use project tooling
PATH="~/go/bin:${PATH}"

# Make sure to start with a clean 'manifests' dir
rm -rf yamls
mkdir -p yamls

# Calling gojsontoyaml is optional, but we would like to generate yaml, not json
jsonnet -m yamls "${1-example.jsonnet}" | xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml' -- {}

# Make sure to remove json files
find yamls -type f ! -name '*.yaml' -delete
rm -f kustomization