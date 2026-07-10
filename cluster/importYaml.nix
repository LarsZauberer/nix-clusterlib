{ lib, ... }:
{
  pkgs,
  object,
}:
builtins.fromJSON (
  builtins.readFile (
    pkgs.runCommand "import-yaml.json" { } ''
      ${pkgs.yq}/bin/yq -s -c . ${lib.escapeShellArg "${object}"} > $out
    ''
  )
)
