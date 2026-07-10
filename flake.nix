{
  description = "My personal quick library to create kubernetes manifest with kubenix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    {
      lib = (import ./cluster) { lib = nixpkgs.lib; };
    };
}
