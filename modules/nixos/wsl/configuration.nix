{ config, pkgs, lib, ... }:

with lib;

let
  kitty-launcher = pkgs.stdenv.mkDerivation rec {
    name = "kitty-launcher";
    dontbuild = true;
    unpackPhase = "true";
    desktopItem = pkgs.makeDesktopItem {
      name = "kitty-launcher";
      exec = "${pkgs.kitty}/bin/kitty";
      desktopName = "kitty-launcher";
      terminal = false;
    };
    installPhase = ''
      mkdir -p $out/share
      cp -r ${desktopItem}/share/applications $out/share
    '';
  };

in
{
  imports = [
    ../common.nix
  ];

  wsl = {
    enable = true;
    defaultUser = mkDefault "alialabbas";
    startMenuLaunchers = true;
    nativeSystemd = true;
    wslConf = {
      network = {
        hostname = mkDefault "wsl";
      };
    };
  };

  # TODO: this should be in home-manager, need to figure out why it is not working
  environment.systemPackages = [
    kitty-launcher
  ];
}
