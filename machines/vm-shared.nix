{ config, pkgs, lib, hostname, ... }:

{
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
   };

  hardware.video.hidpi.enable = true;

  networking.hostName = hostname;

  time.timeZone = "America/Toronto";

  networking.useDHCP = false;

  security.sudo.wheelNeedsPassword = false;

  virtualisation.docker.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver = {
    enable = true;
    layout = "us";
    dpi = 220;

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "fill";
    };

    displayManager = {
      defaultSession = "none+i3";
      lightdm.enable = true;

    };

    windowManager = {
      i3.enable = true;
    };
  };

  users.mutableUsers = false;

  fonts = {
    fontDir.enable = true;

    fonts = [
      pkgs.fira-code
    ];
  };

  environment.systemPackages = with pkgs; [
    gnumake
    killall
    rxvt_unicode
    xclip
    # TODO: this should probably be in home-manager.nix but I can't figure how to make nix install it in the correct path for the wsl to pick it up
    kitty-launcher
  ];

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = true;
  services.openssh.permitRootLogin = "no";


  # This is workaround Hyper-V not support hi resolution monitors natively
  # Couldn't figure out why hyperv sock won't connect correctly using HyperV but this works fine since I rarely need it
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "${pkgs.i3}/bin/i3";

  services.k3s.enable = true;
  services.k3s.extraFlags = toString [
    # we disable traefik and metric server since we manage our own
    "--disable traefik"
    "--disable metrics-server"
  ];


  # make it easier to connect through RDP using hostname.local
  services.avahi = {
    enable = true;
    publish = {
       enable = true;
       addresses = true;
       workstation = true;
    };
  };

  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
