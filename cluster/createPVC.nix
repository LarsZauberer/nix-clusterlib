{
  lib,
  ...
}:
{
  name,
  size,
  namespace,
  class ? "ceph-filesystem",
  many ? true,
}:
{
  persistentVolumeClaims.${name + "-pvc"} = {
    metadata.namespace = namespace;
    spec = {
      storageClassName = class;
      accessModes = [
        (if many then "ReadWriteMany" else "ReadWriteOnce")
      ];
      resources.requests.storage = "${toString size}Gi";
    };
  };
}
