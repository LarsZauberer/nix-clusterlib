{
  lib,
  ...
}:
# Dynamically-provisioned S3 bucket via an ObjectBucketClaim. Rook creates the
# bucket and writes its endpoint + credentials into a ConfigMap and a Secret that
# both share the claim's { name } in the same namespace:
#   ConfigMap keys: BUCKET_NAME, BUCKET_HOST, BUCKET_PORT
#   Secret keys:    AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
# A pod consumes them with envFrom the ConfigMap + Secret.
# { name, namespace, bucketName ? name, class ? <object store class> }
{
  name,
  namespace,
  bucketName ? name,
  class ? "ceph-objectstore",
}:
{
  objectBucketClaim.${name} = {
    metadata.namespace = namespace;
    spec = {
      inherit bucketName;
      storageClassName = class;
    };
  };
}
