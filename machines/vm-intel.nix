{ config, pkgs, ... }: {
  imports = [
    ./vm-shared.nix
  ];

  # Be careful updating this.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  virtualisation.hypervGuest.enable = true;
  virtualisation.hypervGuest.videoMode = "3440x1440";

  # Interface is this on Intel Hyper-V
  networking.interfaces.eth0.useDHCP = true;
  nixpkgs.config.allowUnfree = true;

}
