{
  ...
}:
# NFS-backed volume: same shape as createPVC, just defaults to the CephNFS
# StorageClass. { name, size, namespace, class ? <nfs class> }
args:
(import ./createPVC.nix { inherit lib config; }) (
  {
    class = "ceph-nfs";
    many = true;
  }
  // args
)
