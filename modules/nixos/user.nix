{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.systemConfig;
in
{
  options.modules.systemConfig = {
    user = mkOption {
      type = types.str;
    };
  };

  config = {
    users.users.${cfg.user} = {
      isNormalUser = true;
      home = "/home/" + cfg.user;
      extraGroups = [ "docker" "wheel" ];
      shell = pkgs.bash;
      hashedPassword = "$6$zApfI1uV39la2Kpa$HFEC4w/2tiQK8pCJ0HJyt9kVX6mbpi.BIhIRhi5YEiCSLcg6vFrI4AVH.Kt8d/XCUCMqBwg.1Bzzo1rIlPZQe/";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZaz65Zac9ETYx7Z1NlHtZDNLB/9DP08mUHHuUSiNOR alina@Gaming-Desktop"
      ];
    };
  };
}
