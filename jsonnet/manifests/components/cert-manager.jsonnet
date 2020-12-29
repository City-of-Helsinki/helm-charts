local kube = import '../vendor/kube-libsonnet/kube.libsonnet';
local apiGroup = 'cert-manager.io/v1';

{
  // create simple to use certificate resource
  Certificate(namespace, name, domains, issuerName="certificate-letsencrypt-staging", issuerKind="ClusterIssuer", issuerGroup="cert-manager.io"):: kube._Object(apiGroup, 'Certificate', name) + {
    metadata+: {
      namespace: namespace,
      name: name,
    },
    spec+: {
      secretName: name + '-tls',
      dnsNames: domains,
      issuerRef: {
        group: issuerGroup,
        name: issuerName,
        kind: issuerKind,
      },
    },
  },
}
