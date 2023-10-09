{ lib, ... }:

{
  xdg.configFile."i3/config".text = builtins.readFile ../../../dotfiles/i3;

  programs.i3status = {
    enable = true;

    general = {
      colors = true;
      color_good = "#8C9440";
      color_bad = "#A54242";
      color_degraded = "#DE935F";
    };

    modules = {
      ipv6.enable = lib.mkDefault false;
      "ethernet _first_".enable = lib.mkDefault false;
      load.enable = lib.mkDefault false;
      "volume master" = {
        position = 1;
        settings = {
          format = "♪ %volume";
          format_muted = "♪ %volume";
          device = "default";
        };
      };
      "battery all" = {
        settings = {
          format = " %status %percentage %remaining";
          format_down = "No battery";
          last_full_capacity = true;
          integer_battery_capacity = true;
          status_chr = "⚡";
          status_bat = "🔋";
          status_unk = "";
          status_full = "🔋";
          low_threshold = 20;
          threshold_type = "time";
        };
      };
      "cpu_usage" = {
        position = 6;
        settings = {
          format = "%usage ";
        };
      };
      memory = {
        settings = {
          format = "%used";
          format_degraded = "%used";
        };
      };
      "tztime local" = {
        position = 8;
        settings = {
          format = "📅 %A %Y-%m-%d ";
        };
      };
      "time" = {
        position = 9;
        settings = {
          format = "🕧 %H:%M ";
        };
      };
    };
  };
}
