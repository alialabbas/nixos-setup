{ config, pkgs, lib, ... }:

with lib;


{
  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    gc.automatic = true;
    gc.options = "--delete-older-than 14d";
    optimise.automatic = true;
  };

  networking = {
    firewall = {
      enable = false;
    };
    useDHCP = lib.mkDefault true;
  };

  time.timeZone = "America/Toronto";


  security.sudo.wheelNeedsPassword = false;

  virtualisation.docker = {
    enable = lib.mkDefault true;
    autoPrune.enable = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  users.mutableUsers = false;

  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
    ];
  };

  # make it easier to connect through RDP using hostname.local
  services.avahi = {
    enable = lib.mkDefault true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.displayManager = {
    defaultSession = "none+i3";
  };

  services.xserver = {
    enable = lib.mkDefault true;
    xkb.layout = "us";

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "fill";
    };

    displayManager.gdm.enable = lib.mkDefault false; # This is just to bypass freaking hyperv
    displayManager.lightdm.enable = lib.mkDefault true;


    windowManager = {
      i3.enable = true;
    };
  };

  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # xrdp until I fugure out how to hyperv enchanced session works
  services.xrdp = {
    enable = lib.mkDefault true;
    defaultWindowManager = "${pkgs.i3}/bin/i3";
  };

  environment.systemPackages = with pkgs; [
    gnumake
    killall
    rxvt-unicode-unwrapped
    xclip
    alsa-utils

  ];

  system.stateVersion = "20.09";
}
