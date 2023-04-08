# build a nixos config and diff it against the current one in the system
{ nvd, writeShellScriptBin }:

writeShellScriptBin "nix-build-diff" ''
  nixos-rebuild build "$@" && ${nvd}/bin/nvd diff /run/current-system result
''

