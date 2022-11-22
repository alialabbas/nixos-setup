{ config, pkgs, modulesPath, user, hostname, ... }:

{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    ./vm-shared.nix
  ];

  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = user;
    startMenuLaunchers = true;
    wslConf = {
      network = {
        hostname = hostname;
      };
    };
  };
}
