{
  lib,
  ...
}:
{
  name,
  namespace,
  image,
  ports ? [ ],
  volumes ? [ ],
  secretVolumes ? [ ],
  configMapVolumes ? [ ],
  env ? { },
  envSecrets ? { },
  replicas ? 1,
  rollout ? true,
  problemTolerationTime ? 30,
  resources ? null,
  livenessProbe ? null,
  startupProbe ? null,
  interactive ? false,
}:
let
  volumeMount =
    x:
    {
      inherit (x) name mountPath;
    }
    // lib.optionalAttrs (x ? readOnly) { inherit (x) readOnly; }
    // lib.optionalAttrs (x ? subPath) { inherit (x) subPath; }
    // lib.optionalAttrs (x ? subPathExpr) { inherit (x) subPathExpr; };

  pvcVolume = x: {
    name = x.name;
    persistentVolumeClaim.claimName = x.claimName or (x.name + "-pvc");
  };

  secretVolume =
    x:
    {
      name = x.name;
      secret =
        {
          secretName = x.secretName or x.name;
        }
        // lib.optionalAttrs (x ? items) { inherit (x) items; }
        // lib.optionalAttrs (x ? defaultMode) { inherit (x) defaultMode; }
        // lib.optionalAttrs (x ? optional) { inherit (x) optional; };
    };

  configMapVolume =
    x:
    {
      name = x.name;
      configMap =
        {
          name = x.configMapName or x.name;
        }
        // lib.optionalAttrs (x ? items) { inherit (x) items; }
        // lib.optionalAttrs (x ? defaultMode) { inherit (x) defaultMode; }
        // lib.optionalAttrs (x ? optional) { inherit (x) optional; };
    };
in
{
  deployments.${name} = {
    metadata.labels.app = name;
    metadata.namespace = namespace;
    spec = {
      replicas = replicas;
      strategy.type = if rollout then "RollingUpdate" else "Recreate";
      selector.matchLabels.app = name;
      template = {
        metadata.labels.app = name;
        spec = {
          tolerations =
            let
              noExecute = x: {
                key = "node.kubernetes.io/" + x;
                operator = "Exists";
                effect = "NoExecute";
                tolerationSeconds = problemTolerationTime;
              };
              noSchedule = x: {
                key = "node.kubernetes.io/" + x;
                operator = "Exists";
                effect = "NoSchedule";
              };
            in
            [
              (noExecute "not-ready")
              (noExecute "unreachable")
              (noSchedule "memory-pressure")
              (noSchedule "disk-pressure")
            ];
          volumes =
            (lib.map pvcVolume volumes)
            ++ (lib.map secretVolume secretVolumes)
            ++ (lib.map configMapVolume configMapVolumes);
          containers = [
            {
              name = name;
              image = image;
              ports = lib.map (x: {
                containerPort = x.port;
                protocol = x.protocol or "TCP";
              }) ports;
              volumeMounts = lib.map volumeMount (volumes ++ secretVolumes ++ configMapVolumes);
              env =
                let
                  simpleEnvs = lib.map (key: {
                    name = key;
                    value = env.${key};
                  }) (builtins.attrNames env);
                  secretEnvs = lib.map (key: {
                    name = key;
                    valueFrom.secretKeyRef = {
                      name = envSecrets.${key};
                      key = "secret";
                    };
                  }) (builtins.attrNames envSecrets);
                in
                simpleEnvs ++ secretEnvs;
              stdin = interactive;
              tty = interactive;
              resources = if isNull resources then { } else resources;
              livenessProbe =
                if isNull livenessProbe then
                  null
                else
                  {
                    httpGet = {
                      path = livenessProbe.path;
                      port = livenessProbe.port;
                    };
                    failureThreshold = livenessProbe.fails or 30;
                    periodSeconds = livenessProbe.period or 10;
                  };
              startupProbe =
                if isNull startupProbe then
                  null
                else
                  {
                    httpGet = {
                      path = startupProbe.path;
                      port = startupProbe.port;
                    };
                    failureThreshold = startupProbe.fails or 30;
                    periodSeconds = startupProbe.period or 10;
                  };
            }
          ];
        };
      };
    };
  };
}
