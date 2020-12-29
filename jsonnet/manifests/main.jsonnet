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
               'https://gangway' + $.base_domain + '/callback',
             ],
           },
    }
  else
    {},

  gangway: gangway {
    local this = self,
    base_domain:: $.cluster_domain,
    p:: $.p,
    metadata:: {
      metadata+: {
        namespace: $.namespace,
      },
    },

    // configure let's encrypt root by default
    configMap+: {
      data+: {
        'cluster-ca.crt': |||
          -----BEGIN CERTIFICATE-----
          MIIEkjCCA3qgAwIBAgIQCgFBQgAAAVOFc2oLheynCDANBgkqhkiG9w0BAQsFADA/
          MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
          DkRTVCBSb290IENBIFgzMB4XDTE2MDMxNzE2NDA0NloXDTIxMDMxNzE2NDA0Nlow
          SjELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUxldCdzIEVuY3J5cHQxIzAhBgNVBAMT
          GkxldCdzIEVuY3J5cHQgQXV0aG9yaXR5IFgzMIIBIjANBgkqhkiG9w0BAQEFAAOC
          AQ8AMIIBCgKCAQEAnNMM8FrlLke3cl03g7NoYzDq1zUmGSXhvb418XCSL7e4S0EF
          q6meNQhY7LEqxGiHC6PjdeTm86dicbp5gWAf15Gan/PQeGdxyGkOlZHP/uaZ6WA8
          SMx+yk13EiSdRxta67nsHjcAHJyse6cF6s5K671B5TaYucv9bTyWaN8jKkKQDIZ0
          Z8h/pZq4UmEUEz9l6YKHy9v6Dlb2honzhT+Xhq+w3Brvaw2VFn3EK6BlspkENnWA
          a6xK8xuQSXgvopZPKiAlKQTGdMDQMc2PMTiVFrqoM7hD8bEfwzB/onkxEz0tNvjj
          /PIzark5McWvxI0NHWQWM6r6hCm21AvA2H3DkwIDAQABo4IBfTCCAXkwEgYDVR0T
          AQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwfwYIKwYBBQUHAQEEczBxMDIG
          CCsGAQUFBzABhiZodHRwOi8vaXNyZy50cnVzdGlkLm9jc3AuaWRlbnRydXN0LmNv
          bTA7BggrBgEFBQcwAoYvaHR0cDovL2FwcHMuaWRlbnRydXN0LmNvbS9yb290cy9k
          c3Ryb290Y2F4My5wN2MwHwYDVR0jBBgwFoAUxKexpHsscfrb4UuQdf/EFWCFiRAw
          VAYDVR0gBE0wSzAIBgZngQwBAgEwPwYLKwYBBAGC3xMBAQEwMDAuBggrBgEFBQcC
          ARYiaHR0cDovL2Nwcy5yb290LXgxLmxldHNlbmNyeXB0Lm9yZzA8BgNVHR8ENTAz
          MDGgL6AthitodHRwOi8vY3JsLmlkZW50cnVzdC5jb20vRFNUUk9PVENBWDNDUkwu
          Y3JsMB0GA1UdDgQWBBSoSmpjBH3duubRObemRWXv86jsoTANBgkqhkiG9w0BAQsF
          AAOCAQEA3TPXEfNjWDjdGBX7CVW+dla5cEilaUcne8IkCJLxWh9KEik3JHRRHGJo
          uM2VcGfl96S8TihRzZvoroed6ti6WqEBmtzw3Wodatg+VyOeph4EYpr/1wXKtx8/
          wApIvJSwtmVi4MFU5aMqrSDE6ea73Mj2tcMyo5jMd6jmeWUHK8so/joWUoHOUgwu
          X4Po1QYz+3dszkDqMp4fklxBwXRsW10KXzPMTZ+sOPAveyxindmjkW8lGy+QsRlG
          PfZ+G6Z6h7mjem0Y+iWlkYcV4PIWL1iwBi8saCbGS5jN2p8M+X+Q7UNKEkROb3N6
          KOqkqm57TH2H3eDJAkSnh6/DNFu0Qg==
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
