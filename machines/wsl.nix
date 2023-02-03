{ config, pkgs, modulesPath, user, hostname, ... }:

{
  imports = [
    ./vm-shared.nix
  ];

  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = user;
    startMenuLaunchers = true;
    nativeSystemd = true;
    wslConf = {
      network = {
        hostname = hostname;
      };
    };
  };
}
