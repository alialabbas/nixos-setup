{ lib, pkgs, config, ... }:

let
  myPkgs = lib.attrValues (import ../../lib/pkgsBuilder.nix { inherit pkgs lib; } ../../pkgs);
in
{

  imports = import ../../lib/mkImportPaths.nix { inherit lib; } ./.;

  xdg.enable = true;

  home = {
    stateVersion = "22.11";
    username = "alialabbas";
    homeDirectory = "/home/alialabbas";
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs;[
    bat
    fd
    htop
    ripgrep
    tree
    watch
    (with dotnetCorePackages; combinePackages [
      sdk_8_0
      sdk_9_0
    ])
    go
    yq
    jq
    nickel
    nvd
  ] ++ myPkgs;

  programs.bash.initExtra = builtins.readFile ./dotnet.sh;

  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        search = {
          force = true;
          engines = {
            "Nix Packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  { name = "type"; value = "packages"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];
              icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "Nix Options" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  { name = "type"; value = "options"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];
              icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@no" ];
            };
            "NixOS Wiki" = {
              urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
              icon = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@nw" ];
            };
            "bing".metaData.hidden = true;
            "google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
          };
        };
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          bitwarden
        ];
      };
    };
  };
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
    TERMINAL = "${pkgs.kitty}/bin/kitty";
  };

  programs.readline = {
    enable = lib.mkDefault true;
    variables = {
      show-all-if-ambiguous = "on";
      completion-ignore-case = "on";
    };
    extraConfig = ''
      $if Bash
        Space: magic-space
      $endif
    '';

  };

  programs.tmux = {
    enable = lib.mkDefault true;
    terminal = "xterm-256color";
    secureSocket = false;
    keyMode = "vi";
    plugins = with pkgs.tmuxPlugins; [
      sidebar
      pain-control
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-show-powerline true
          set -g @dracula-plugins "cpu-usage ram-usage weather time"
          set -g @dracula-show-fahrenheit false
        '';
      }
    ];

    extraConfig = ''
      set -ga terminal-overrides ",*256col*:Tc"
      set -g @dracula-show-fahrenheit false
    '';
  };

  programs.kitty = {
    enable = lib.mkDefault true;
    font = {
      package = pkgs.nerd-fonts.fira-code;
      name = "FiraCode Nerd Font Mono";
      size = 10;
    };
    keybindings = {
      "super+v" = "paste_from_clipboard";
      "super+c" = "copy_or_interrupt";
      "super+equal" = "increase_font_size";
      "super+minus" = "decrease_font_size";
      "super+shift+g" = "show_last_command_output";
      "super+ctrl+p" = "scroll_to_prompt -1";
      "super+ctrl+n" = "scroll_to_prompt 1";
      "super+y" = "launch --stdin-source=@last_cmd_output --type=clipboard";
      "ctrl+shift+z" = "goto_layout stack";
      "alt+shift+z" = "goto_layout tall";
      "kitty_mod+enter" = "new_window_with_cwd";
    };
    settings = {
      enable_audio_bell = false;
      linux_display_server = "x11";
      cursor_trail = 3;
    };
    themeFile = "OneHalfDark";
    shellIntegration.enableBashIntegration = true;
  };

  programs.fzf = {
    enable = lib.mkDefault true;
    enableBashIntegration = true;
    tmux.enableShellIntegration = true;
  };

  programs.starship = {
    enable = lib.mkDefault true;
    enableBashIntegration = true;
    settings = {
      battery = {
        disabled = true;
      };
      container = {
        disabled = true;
      };
    };
  };

  xresources = {
    properties = {
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

  programs.bat = {
    config.theme = "OneHalfDark";
    enable = true;
  };
}
