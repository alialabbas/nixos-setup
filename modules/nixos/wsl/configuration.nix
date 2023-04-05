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

  cfg = config.modules.systemConfig;
in
{
  imports = [
    ../common.nix
  ];

  wsl = {
    enable = true;
    defaultUser = cfg.user;
    startMenuLaunchers = true;
    nativeSystemd = true;
    wslConf = {
      network = {
        hostname = cfg.hostname;
      };
    };
  };
  environment.systemPackages = [
    kitty-launcher
  ];
}
