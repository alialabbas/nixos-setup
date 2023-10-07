{ pkgs, lib, config, ... }:

{
  imports = [
    ../common.nix
    ../vim/vim.nix
    ../git/git.nix
    ../bash/bash.nix
    ../neovim/neovim.nix
  ];

  home.packages = with pkgs; [
    firefox
    xdotool
    rofi-bluetooth # manage bluetooth using rofi
    # networkmanagerapplet
  ];

  # TODO: convert i3 fully to home-manager to make it possible to bootstrap a full ubuntu experience if needed
  # Also I don't want random config files
  xdg.configFile."i3/config".text = builtins.readFile ../../../dotfiles/i3;
  # xdg.configFile."rofi/config.rasi".text = builtins.readFile ../../../dotfiles/rofi;

  programs.rofi = {
    enable = lib.mkDefault true;
    cycle = true;
    terminal = "${pkgs.kitty}/bin/kitty";
    theme =
      let
        inherit (config.lib.formats.rasi) mkLiteral;
      in
      {
        # onehalf dark
        "*" = {
          black = mkLiteral "#000000";
          red = mkLiteral "#eb6e67";
          green = mkLiteral "#95ee8f";
          yellow = mkLiteral "#f8c456";
          blue = mkLiteral "#6eaafb";
          purple = mkLiteral "#d886f3";
          cyan = mkLiteral "#6cdcf7";
          emphasis = mkLiteral "#50536b";
          text = mkLiteral "#dfdfdf";
          text-alt = mkLiteral "#b2b2b2";
          fg = mkLiteral "#abb2bf";
          bg = mkLiteral "#282c34";
          spacing = 0;
          background-color = mkLiteral "transparent";
          font = "Knack Nerd Font 14";
          text-color = mkLiteral "@text";
        };

        window = {
          transparency = "screenshot";
          fullscreen = false;
          background-color = mkLiteral "#282c34dd";
          border = 1;
          border-radius = 6;
          padding = 5;
        };

        mainbox = {
          border = 0;
          padding = 0;
        };

        inputbar = {
          margin = mkLiteral "0px 0px 20px 0px";
          children = map mkLiteral [ "prompt" "textbox-prompt-colon" "entry" "case-indicator" ];
        };

        prompt = {
          text-color = mkLiteral "@blue";
        };

        textbox-prompt-colon = {
          expand = false;
          str = ":";
          text-color = mkLiteral "@text-alt";
        };

        entry = {
          margin = mkLiteral "0px 10px";
        };

        listview = {
          spacing = mkLiteral "5px";
          dynamic = true;
          scrollbar = false;
        };

        element = {
          padding = mkLiteral "5px";
          text-color = mkLiteral "@text-alt";
          highlight = mkLiteral "bold #95ee8f";
          border-radius = mkLiteral "3px";
        };

        "element selected" = {
          background-color = mkLiteral "@emphasis";
          text-color = mkLiteral "@text";
        };

        "element urgent, element selected urgent" = {
          text-color = mkLiteral "@red";
        };

        "element active, element selected active" = {
          text-color = mkLiteral "@purple";
        };

        message = {
          padding = mkLiteral "5px";
          border-radius = mkLiteral "3px";
          backgrund-color = mkLiteral "@emphasis";
          border = mkLiteral "1px";
          border-color = mkLiteral "@cyan";
        };

        "button selected" = {
          padding = mkLiteral "5px";
          border-radius = mkLiteral "3px";
          background-color = mkLiteral "@emphasis";
        };
      };
  };

  programs.i3status = {
    enable = true;

    general = {
      colors = true;
      color_good = "#8C9440";
      color_bad = "#A54242";
      color_degraded = "#DE935F";
    };

    modules = {
      ipv6.enable = false;
      "ethernet _first_".enable = false;
      load.enable = false;
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

  services.fusuma = {
    enable = true;
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

  xresources = {
    #extraConfig = builtins.readFile ../../../dotfiles/Xresources;
    properties = {
      "Xft.dpi" = 180;
      "Xft.autohint" = true;
      "Xft.antialias" = true;
      "Xft.hinting" = true;
      "Xft.hintstyle" = "hintslight";
      "Xft.rgba" = "rgb";
      "Xft.lcdfilter" = "lcddefault";

      # terminal colors
      "*background" = "#1D1F21";
      "*foreground" = "#C5C8C6";
      "*cursorColor" = "#C3FF00";

      # black
      "*color0" = "#282A2E";
      "*color8" = "#373B41";
      # red
      "*color1" = "#A54242";
      "*color9" = "#CC6666";
      # green
      "*color2" = "#8C9440";
      "*color10" = "#B5BD68";
      # yellow
      "*color3" = "#DE935F";
      "*color11" = "#F0C674";
      # blue
      "*color4" = "#5F819D";
      "*color12" = "#81A2BE";
      # magenta
      "*color5" = "#85678F";
      "*color13" = "#B294BB";
      # cyan
      "*color6" = "#5E8D87";
      "*color14" = "#8ABEB7";
      # white
      "*color7" = "#707880";
      "*color15" = "#C5C8C6";

      # URXVT
      # Colors
      # bold, italic, underline
      "URxvt.colorBD" = "#B5BD68";
      "URxvt.colorIT" = "#B294BB";
      "URxvt.colorUL" = "#81A2BE";
    };
  };


}












