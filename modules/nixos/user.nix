{ pkgs, config, ... }:

let
  groups = builtins.filter (x: x != "") [
    (if config.virtualisation.docker.enable then "docker" else "")
    (if config.services.libinput.enable then "input" else "")
    (if config.networking.networkmanager.enable then "networkmanager" else "")
    (if config.services.xserver.enable then "video" else "")
  ];
in
{
  users.users.alialabbas = {
    isNormalUser = true;
    home = "/home/alialabbas";
    extraGroups = [ "wheel" ] ++ groups;
    shell = pkgs.bash;
    hashedPassword = "$6$zApfI1uV39la2Kpa$HFEC4w/2tiQK8pCJ0HJyt9kVX6mbpi.BIhIRhi5YEiCSLcg6vFrI4AVH.Kt8d/XCUCMqBwg.1Bzzo1rIlPZQe/";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZaz65Zac9ETYx7Z1NlHtZDNLB/9DP08mUHHuUSiNOR alina@Gaming-Desktop"
    ];
  };
}
