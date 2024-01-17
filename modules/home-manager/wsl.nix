{ pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  home.sessionVariables = {
    BROWSER = "${pkgs.wslu}/bin/wslview";
  };

  home.packages = [
    pkgs.wslu
  ];
}
