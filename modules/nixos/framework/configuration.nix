{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    ../common.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "uas"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
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

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config.allowUnfree = lib.mkDefault true;
  services.libinput = {
    enable = lib.mkDefault true;
    touchpad.horizontalScrolling = true;
  };


  services.openssh.enable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  networking.networkmanager.enable = lib.mkDefault true;

  sound.enable = lib.mkDefault true;

  services.pipewire = {
    enable = lib.mkDefault true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.logind.lidSwitch = "suspend-then-hibernate";

  # TODO: looks like there should be a firmware update for fingerprint device to allow this to work for 13th intel gen frameworks
  # Check this again when 23.11 is out
  services.fprintd = {
    enable = lib.mkDefault true;
    # tod.enable = true;
    # tod.driver = pkgs.libfprint-2-tod1-goodix;
  };

  services.fwupd.enable = lib.mkDefault true;

  environment.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";
  };

  services.xrdp.enable = false;

  hardware.bluetooth.enable = lib.mkDefault true;

  networking.hostName = "dev-laptop";
  programs.nix-ld.enable = true;
}
