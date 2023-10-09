{ pkgs, lib, config, ... }:

{
  imports = [
    ./common.nix
  ];

  services.fusuma = {
    enable = lib.mkDefault true;
    extraPackages = with pkgs; [ coreutils xdotool i3 ];

    settings = {
      swipe = {
        "3" = {
          left = {
            command = "i3 focus right";
          };
          right = {
            "command" = "i3 focus left";
          };
          up = {
            "command" = "i3 focus down";
          };
          down = {
            "command" = "i3 focus up";
          };
        };
        "4" = {
          left = {
            "command" = "i3 workspace next";
          };
          right = {
            "command" = "i3 workspace prev";
          };
          up = {
            "command" = "i3 fullscreen toggle";
          };
          down = {
            "command" = "exec rofi -show window";
          };
        };
      };
      threshold = {
        swipe = 0.4;
        pinch = 0.4;
      };
      interval = {
        swipe = 0.8;
        pinch = 0.1;
      };
    };
  };
}
