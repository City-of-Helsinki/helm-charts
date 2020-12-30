local kube = import './vendor/kube-libsonnet/kube.libsonnet';


local cert_manager = import './components/cert-manager.jsonnet';
local dex = import './components/dex.jsonnet';
local gangway = import './components/gangway.jsonnet';
local kube_oidc_proxy = import './components/kube-oidc-proxy.jsonnet';

local removeLeadingDot(s) = if std.startsWith(s, '.') then
  std.substr(s, 1, std.length(s) - 1)
else
  s;

local Ingress(namespace, name, domain, serviceName, servicePort, sslPassthrough=true, issuerName="certificate-letsencrypt-staging") = {
  apiVersion: 'extensions/v1beta1',
  kind: 'Ingress',
  metadata: {
    name: name,
    namespace: namespace,
    annotations: {
      "kubernetes.io/ingress.class": "nginx",
    } + if sslPassthrough then {
      "nginx.ingress.kubernetes.io/ssl-passthrough": "true",
      "nginx.ingress.kubernetes.io/backend-protocol": "HTTPS",
      "nginx.ingress.kubernetes.io/ssl-redirect": "true",
      
    } else {
      "cert-manager.io/cluster-issuer": issuerName
    },
  },
  spec: { 
    rules: [
      {
        host: domain,
        http: {
          paths: [{
            backend: {
              serviceName: serviceName,
              servicePort: servicePort,
            },
            path: "/",
          }],
        },
      }
    ]
  } + if !sslPassthrough then {
    tls: [
      {
        hosts: [domain],
        secretName: name+"-cert",
      },
    ],
  }
  else {},
};

{

  config:: import '../secrets.json',

  master:: true,

  base_domain:: error 'base_domain is undefined',

  cluster_domain:: $.base_domain,

  dex_domain:: 'dex' + $.base_domain,

  p:: '',

  default_replicas:: 1,

  namespace:: 'auth',

  ns: kube.Namespace($.namespace),

  sslPassthroughDomains:: [],

  dex: if $.master then
    dex {
      local this = self,
      domain:: $.dex_domain,
      p:: $.p,
      metadata:: {
        metadata+: {
          namespace: $.namespace,
        },
      },

      deployment+: {
        spec+: {
          replicas: $.default_replicas,
        },
      },

      certificate: cert_manager.Certificate(
        $.namespace,
        this.name,
        [this.domain]
      ),

      ingress: Ingress($.namespace, this.name, this.domain, this.name, 5556),

      connectors: [],

      users: [],

      client: dex.Client($.config.gangway.client_id) + $.dex.metadata {
             secret: $.config.gangway.client_secret,
             redirectURIs: [
               'https://into' + $.base_domain + '/callback',
             ],
           },
    }
  else
    {},

  gangway: gangway {
    local this = self,
    base_domain:: $.cluster_domain,
    domain:: "into" + $.base_domain,
    p:: $.p,
    metadata:: {
      metadata+: {
        namespace: $.namespace,
      },
    },

    // configure let's encrypt root by default
    // Root at https://letsencrypt.org/certs/
    configMap+: {
      data+: {
        'cluster-ca.crt': |||
          -----BEGIN CERTIFICATE-----
          MIIDSjCCAjKgAwIBAgIQRK+wgNajJ7qJMDmGLvhAazANBgkqhkiG9w0BAQUFADA/
          MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
          DkRTVCBSb290IENBIFgzMB4XDTAwMDkzMDIxMTIxOVoXDTIxMDkzMDE0MDExNVow
          PzEkMCIGA1UEChMbRGlnaXRhbCBTaWduYXR1cmUgVHJ1c3QgQ28uMRcwFQYDVQQD
          Ew5EU1QgUm9vdCBDQSBYMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
          AN+v6ZdQCINXtMxiZfaQguzH0yxrMMpb7NnDfcdAwRgUi+DoM3ZJKuM/IUmTrE4O
          rz5Iy2Xu/NMhD2XSKtkyj4zl93ewEnu1lcCJo6m67XMuegwGMoOifooUMM0RoOEq
          OLl5CjH9UL2AZd+3UWODyOKIYepLYYHsUmu5ouJLGiifSKOeDNoJjj4XLh7dIN9b
          xiqKqy69cK3FCxolkHRyxXtqqzTWMIn/5WgTe1QLyNau7Fqckh49ZLOMxt+/yUFw
          7BZy1SbsOFU5Q9D8/RhcQPGX69Wam40dutolucbY38EVAjqr2m7xPi71XAicPNaD
          aeQQmxkqtilX4+U9m5/wAl0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNV
          HQ8BAf8EBAMCAQYwHQYDVR0OBBYEFMSnsaR7LHH62+FLkHX/xBVghYkQMA0GCSqG
          SIb3DQEBBQUAA4IBAQCjGiybFwBcqR7uKGY3Or+Dxz9LwwmglSBd49lZRNI+DT69
          ikugdB/OEIKcdBodfpga3csTS7MgROSR6cz8faXbauX+5v3gTt23ADq1cEmv8uXr
          AvHRAosZy5Q6XkjEGB5YGV8eAlrwDPGxrancWYaLbumR9YbK+rlmM6pZW87ipxZz
          R8srzJmwN0jP41ZL9c8PDHIyh8bwRLtTcm1D9SZImlJnt1ir/md2cXjbDaJWFBM5
          JDGFoqgCWjBH4d1QB7wCCZAA62RjYJsWvIjJEubSfZGL+T0yjWW06XyxV3bqxbYo
          Ob8VZRzI9neWagqNdwvYkQsEjgfbKbYK7p2CNTUQ
          -----END CERTIFICATE-----
        |||,
      },
    },

    deployment+: {
      spec+: {
        replicas: $.default_replicas,
      },
    },

    certificate: cert_manager.Certificate(
      $.namespace,
      this.name,
      [this.domain]
    ),

    ingress: Ingress($.namespace, this.name, this.domain, this.name, 8080),

    sessionSecurityKey: $.config.gangway.session_security_key,

    config+: {
      authorizeURL: 'https://' + $.dex_domain + '/auth',
      tokenURL: 'https://' + $.dex_domain + '/token',
      apiServerURL: 'https://' + $.kube_oidc_proxy.domain,
      clientID: $.config.gangway.client_id,
      clientSecret: $.config.gangway.client_secret,
      clusterCAPath: this.config_path + '/cluster-ca.crt',
    },
  },

  kube_oidc_proxy: kube_oidc_proxy {
    local this = self,
    base_domain:: $.cluster_domain,
    p:: $.p,
    metadata:: {
      metadata+: {
        namespace: $.namespace,
      },
    },

    config+: {
      oidc+: {
        issuerURL: 'https://' + $.dex_domain,
        clientID: $.config.gangway.client_id,
      },
    },

    deployment+: {
      spec+: {
        replicas: $.default_replicas,
      },
    },

    certificate: cert_manager.Certificate(
      $.namespace,
      this.name,
      [this.domain]
    ),
    ingress: Ingress($.namespace, this.name, this.domain, this.name, 443),
  },
}
