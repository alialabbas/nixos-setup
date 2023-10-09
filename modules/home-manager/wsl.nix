{ pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  home.packages = [
    pkgs.wslu
  ];
}
