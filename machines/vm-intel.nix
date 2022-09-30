{ config, pkgs, ... }: {
  imports = [
    ./vm-shared.nix
  ];

  virtualisation.hypervGuest.enable = true;
  virtualisation.hypervGuest.videoMode = "1920x1080";

  # Interface is this on Intel Hyper-V
  networking.interfaces.eth0.useDHCP = true;
  nixpkgs.config.allowUnfree = true;

}
