{ pkgs, lib, ... }:

{
  imports = [
    ./common.nix
  ];

  programs.i3status = {
    modules = {
      "wireless _first_".enable = false;
      "ethernet _first_".enable = true;
      "battery all".enable = false;
    };
  };

  # Make cursor not tiny on HiDPI screens
  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 128;
    x11.enable = true;
  };
}
