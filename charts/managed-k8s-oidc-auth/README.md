# managed-k8s-oidc-auth

![Version: 0.1.4](https://img.shields.io/badge/Version-0.1.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

A Helm chart for Kubernetes to deploy services needed for OIDC access to managed clusters (AKS, ESK, GKE)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Hi-Fi |  |  |
| City-of-Helsinki |  |  |

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://city-of-helsinki.github.io/managed-k8s-oidc-auth/ | kube-oidc-proxy | 0.3.1 |
| https://gabibbo97.github.io/charts/ | dex | 4.0.2 |
| https://gabibbo97.github.io/charts/ | gangway | 1.0.3 |

Note that also [cert-manager](https://cert-manager.io/docs/installation/kubernetes/#installing-with-helm) should
be available before installation of this chart. It's not recommended to be used as sub-chart.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| RBAC.adminGroups | list | `[]` |  |
| RBAC.developerGroups | list | `[]` |  |
| RBAC.viewerGroups | list | `[]` |  |
| certificate.annotations | string | `nil` |  |
| certificate.issuer | string | `"certificate-letsencrypt-staging"` |  |
| dex.JSONLogging | bool | `true` |  |
| dex.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchLabels."app.kubernetes.io/name" | string | `"dex"` |  |
| dex.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| dex.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| dex.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].podAffinityTerm.labelSelector.matchLabels."app.kubernetes.io/name" | string | `"dex"` |  |
| dex.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].podAffinityTerm.topologyKey | string | `"topology.kubernetes.io/zone"` |  |
| dex.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].weight | int | `100` |  |
| dex.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[2].podAffinityTerm.labelSelector.matchLabels."app.kubernetes.io/name" | string | `"dex"` |  |
| dex.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[2].podAffinityTerm.topologyKey | string | `"failure-domain.beta.kubernetes.io/zone"` |  |
| dex.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[2].weight | int | `100` |  |
| dex.connectors[0].id | string | `"mock"` |  |
| dex.connectors[0].name | string | `"Example connector"` |  |
| dex.connectors[0].type | string | `"mockCallback"` |  |
| dex.enabled | bool | `true` |  |
| dex.ingress.annotations."kubernetes.io/ingress.class" | string | `"nginx"` |  |
| dex.ingress.enabled | bool | `true` |  |
| dex.ingress.hosts[0].host | string | `"dex.example.com"` |  |
| dex.ingress.hosts[0].paths[0] | string | `"/"` |  |
| dex.prometheusOperator.serviceMonitor.enable | bool | `false` |  |
| dex.resources.limits.cpu | string | `"50m"` |  |
| dex.resources.limits.memory | string | `"64Mi"` |  |
| dex.resources.requests.cpu | string | `"50m"` |  |
| dex.resources.requests.memory | string | `"64Mi"` |  |
| dex.staticClients | list | `[]` |  |
| dex.staticPasswords | list | `[]` |  |
| gangway.config.apiServerURL | string | `"https://kube-oidc-proxy.example.com"` |  |
| gangway.config.audience | string | `""` |  |
| gangway.config.authorizeURL | string | `"https://dex.example.com"` |  |
| gangway.config.clusterName | string | `"k8s"` |  |
| gangway.config.scopes[0] | string | `"openid"` |  |
| gangway.config.scopes[1] | string | `"email"` |  |
| gangway.config.scopes[2] | string | `"profile"` |  |
| gangway.config.scopes[3] | string | `"offline_access"` |  |
| gangway.config.scopes[4] | string | `"groups"` |  |
| gangway.config.tokenURL | string | `"https://dex.example.com/token"` |  |
| gangway.enabled | bool | `true` |  |
| gangway.ingress.annotations."kubernetes.io/ingress.class" | string | `"nginx"` |  |
| gangway.ingress.enabled | bool | `true` |  |
| gangway.ingress.hosts[0].host | string | `"into.example.com"` |  |
| gangway.ingress.hosts[0].paths[0] | string | `"/"` |  |
| gangway.resources.limits.cpu | string | `"100m"` |  |
| gangway.resources.limits.memory | string | `"64Mi"` |  |
| gangway.resources.requests.cpu | string | `"50m"` |  |
| gangway.resources.requests.memory | string | `"64Mi"` |  |
| gangway.sessionSecurityKey | string | `"betterSecurityKey"` |  |
| kube-oidc-proxy.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchLabels."app.kubernetes.io/name" | string | `"kube-oidc-proxy"` |  |
| kube-oidc-proxy.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| kube-oidc-proxy.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| kube-oidc-proxy.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].podAffinityTerm.labelSelector.matchLabels."app.kubernetes.io/name" | string | `"kube-oidc-proxy"` |  |
| kube-oidc-proxy.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].podAffinityTerm.topologyKey | string | `"topology.kubernetes.io/zone"` |  |
| kube-oidc-proxy.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].weight | int | `100` |  |
| kube-oidc-proxy.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[2].podAffinityTerm.labelSelector.matchLabels."app.kubernetes.io/name" | string | `"kube-oidc-proxy"` |  |
| kube-oidc-proxy.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[2].podAffinityTerm.topologyKey | string | `"failure-domain.beta.kubernetes.io/zone"` |  |
| kube-oidc-proxy.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[2].weight | int | `100` |  |
| kube-oidc-proxy.cmCertificate | bool | `true` |  |
| kube-oidc-proxy.enabled | bool | `true` |  |
| kube-oidc-proxy.ingress.annotations."kubernetes.io/ingress.class" | string | `"nginx"` |  |
| kube-oidc-proxy.ingress.annotations."nginx.ingress.kubernetes.io/ssl-passthrough" | string | `"true"` |  |
| kube-oidc-proxy.ingress.enabled | bool | `true` |  |
| kube-oidc-proxy.ingress.hosts[0].host | string | `"kube-oidc-proxy.example.com"` |  |
| kube-oidc-proxy.ingress.hosts[0].paths[0] | string | `"/"` |  |
| kube-oidc-proxy.resources.limits.cpu | string | `"100m"` |  |
| kube-oidc-proxy.resources.limits.memory | string | `"64Mi"` |  |
| kube-oidc-proxy.resources.requests.cpu | string | `"50m"` |  |
| kube-oidc-proxy.resources.requests.memory | string | `"64Mi"` |  |
