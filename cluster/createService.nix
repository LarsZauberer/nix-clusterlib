{ lib, ... }:
{
  name,
  app ? name,
  namespace,
  innerPort,
  outerPort ? 80,
  protocol ? "TCP",
  type ? "ClusterIP",
  nodePort ? 1,
}:
{
  services.${
    lib.concatStrings [
      name
      "-svc"
    ]
  } =
    {
      metadata.namespace = namespace;
      spec = {
        type = type;
        selector.app = app;
        ports = [
          (
            {
              name = lib.concatStrings [
                name
                "-svc-port"
              ];
              protocol = protocol;
              targetPort = innerPort;
              port = outerPort;
            }
            // (
              if type == "NodePort" then
                {
                  nodePort = if nodePort == 1 then throw "nodePort is not set on service ${name}" else nodePort;
                }
              else
                { }
            )
          )
        ];
      };
    };
}
