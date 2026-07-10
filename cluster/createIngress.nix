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
          "traefik.ingress.kubernetes.io/router.middlewares" = "${namespace}-${basicAuth}@kubernetescrd";
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
  middlewares.${basicAuth} = {
    metadata.namespace = namespace;
    spec.basicAuth.secret = basicAuth;
    # The secret includes a newline seperates list of `<username>:<special encrypted password>`
    # The key for the secret is `users`
  };
}
