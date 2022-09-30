{ config, pkgs, ... }: {
  # TODO: figure out how to make this work with vm-shared.nix
  imports = [];

  networking.useDHCP = false;

  security.sudo.wheelNeedsPassword = false;


  users.mutableUsers = false;

  fonts = {
    fontDir.enable = true;

    fonts = [
      pkgs.fira-code
    ];
  };

  networking.firewall.enable = false;

}
