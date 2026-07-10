{
  lib,
  ...
}:
# A standalone S3 user on the object store, with its own credentials (independent
# of any bucket). Rook writes the keys into a Secret named
# "rook-ceph-object-user-<store>-<name>" in the Ceph namespace, with keys
# AccessKey and SecretKey. The user must live in the same namespace as the store.
# { name, displayName ? name, store ? <object store name>, namespace ? <ceph ns> }
{
  name,
  displayName ? name,
  store ? "ceph-objectstore",
  namespace ? "rook-ceph",
}:
{
  cephObjectStoreUser.${name} = {
    metadata.namespace = namespace;
    spec = {
      inherit store displayName;
    };
  };
}
