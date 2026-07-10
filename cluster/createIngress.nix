{
  lib,
  ...
}:
{
  name,
  namespace,
  domains,
  port ? 80,
  service ? name + "-svc",
  basicAuth ? null,
  clusterIssuer ? "main-cluster-issuer",
}:
let
  basicAuthName = name + "-basic-auth";
in
{
  ingresses.${
    lib.concatStrings [
      name
      "-ingress"
    ]
  } =
    {
      metadata.namespace = namespace;
      metadata.annotations = lib.mkMerge [
        {
          "cert-manager.io/cluster-issuer" = clusterIssuer;
        }
        (lib.mkIf (basicAuth != null) {
          "traefik.ingress.kubernetes.io/router.middlewares" = "${namespace}-${basicAuthName}@kubernetescrd";
        })
      ];
      spec = {
        tls = [
          {
            hosts = domains;
            secretName = lib.concatStrings [
              name
              "-cert"
            ];
          }
        ];
        rules = lib.map (domain: {
          host = domain;
          http.paths = [
            {
              path = "/";
              pathType = "Prefix";
              backend.service = {
                name = service;
                port.number = port;
              };
            }
          ];
        }) domains;
      };
    };
}
// lib.optionalAttrs (basicAuth != null) {
  # htpasswd file, resolved from agenix. Traefik's BasicAuth reads the "users"
  # key; stringData takes the plaintext htpasswd (k8s base64-encodes it).
  secrets.${basicAuthName} = {
    metadata.namespace = namespace;
    stringData.users = "ref+file:///run/agenix/" + basicAuth;
  };
  middlewares.${basicAuthName} = {
    metadata.namespace = namespace;
    spec.basicAuth.secret = basicAuthName;
    # The secret includes a newline seperates list of `<username>:<special encrypted password>`
    # The key for the secret is `users`
  };
}
