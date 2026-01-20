{ config, pkgs, lib, ... }:

{
  imports = [
    ../common.nix
  ];

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "mptspi"
    "uhci_hcd"
    "ehci_pci"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [ ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # end of generated hardwre

  # Be careful updating this.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  virtualisation.hypervGuest.enable = true;
  virtualisation.hypervGuest.videoMode = "1920x1080";

  networking = {
    # Interface is this on Intel Hyper-V
    interfaces.eth0.useDHCP = true;
    hostName = "dev";
  };

  nixpkgs.config.allowUnfree = true;

  users.users.gdm.extraGroups = [ "video" ];

  services.libinput.enable = true;

  services = {
    displayManager = {
      lightdm.enable = false;
      gdm.enable = true;
    };
  };
}
