local main = import './manifests/main.jsonnet';
local secrets = import './secrets.json';

local manifests = main {
  base_domain: '.newtest.kuva.hel.ninja',
  dex+: if $.master then {
    // users: [
    //   $.dex.Password('admin@example.net', '$2y$10$i2.tSLkchjnpvnI73iSW/OPAVriV9BWbdfM6qemBM1buNRu81.ZG.'),  // plaintext: secure
    // ],
    // This shows how to add dex connectors
    connectors: std.mapWithKey(
        (function(k, v)
          $.dex.Connector(k, v.name, k, {
            clientID: v.client_id,
            clientSecret: v.client_secret,
          } + v.extraSettings)
        ),
        std.prune(secrets.authBackends)
      ),
    }
  else
    {},
};

{ ['0namespace']: manifests.ns } +
{ ['2dex-connectors-' + name]: manifests.dex.connectors[name] for name in std.objectFields(manifests.dex.connectors)} +
{ ['1dex-crd-' + crd.metadata.name]: crd for crd in manifests.dex.crds} +
{ ['1dex-' + name]: manifests.dex[name] for name in std.filter((function(name) !(name == 'crds' || name == 'connectors' || name == 'users')),std.objectFields(manifests.dex)) } +
{ ['1gangway-' + name]: manifests.gangway[name] for name in std.objectFields(manifests.gangway) } +
{ ['1kube_oidc_proxy-' + name]: manifests.kube_oidc_proxy[name] for name in std.objectFields(manifests.kube_oidc_proxy) }