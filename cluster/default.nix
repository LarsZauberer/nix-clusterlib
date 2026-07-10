{ lib, ... }:
{
  createPVC = (import ./createPVC.nix) { inherit lib; };
  createNFS = (import ./createNFS.nix) { inherit lib; };
  createService = (import ./createService.nix) { inherit lib; };
  createIngress = (import ./createIngress.nix) { inherit lib; };
  createDeployment = (import ./createDeployment.nix) { inherit lib; };
  createNamespace = (import ./createNamespace.nix) { inherit lib; };
  createSecret = (import ./createSecret.nix) { inherit lib; };
  createBucket = (import ./createBucket.nix) { inherit lib; };
  createObjectUser = (import ./createObjectUser.nix) { inherit lib; };
  importYaml = (import ./importYaml.nix) { inherit lib; };
}
