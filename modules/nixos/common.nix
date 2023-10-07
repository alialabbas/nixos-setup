{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.systemConfig;
in
{
  options.modules.systemConfig = {
    hostname = mkOption {
      default = "dev";
      type = types.str;
    };
  };

  config = {
    nix = {
      package = pkgs.nixUnstable;
      extraOptions = ''
        experimental-features = nix-command flakes
        keep-outputs = true
        keep-derivations = true
      '';
      gc.automatic = true;
    };

    networking = {
      hostName = cfg.hostname;
      firewall = {
        enable = false;
      };
      useDHCP = lib.mkDefault true;
    };

    time.timeZone = "America/Toronto";


    security.sudo.wheelNeedsPassword = false;

    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
    };

    i18n.defaultLocale = "en_US.UTF-8";

    users.mutableUsers = false;

    fonts = {
      fontDir.enable = true;
      enableDefaultFonts = true;
      fonts = with pkgs; [
        (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
      ];
    };

    # make it easier to connect through RDP using hostname.local
    services.avahi = {
      enable = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    environment.systemPackages = with pkgs; [
      gnumake
      killall
      rxvt_unicode
      xclip
    ];


    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "20.09"; # Did you read the comment?
  };
}
