{ lib, pkgs, ... }:

let
  myPkgs = lib.attrValues (import ../../lib/pkgsBuilder.nix { inherit pkgs lib; });
  rofi-network = pkgs.callPackage ../../rofi-network.nix { };
in
{
  xdg.enable = true;

  home.stateVersion = "22.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs;[
    bat
    fd
    htop
    jq
    ripgrep
    tree
    watch
    dotnet-sdk
    go
    yq
    nvd
    rofi-network
  ] ++ myPkgs;

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
    enable = true;
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
    enable = true;
    #extraConfig = builtins.readFile ../../dotfiles/kitty;
    font = {
      package = (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; });
      name = "Fira Code";
      size = 10;
    };
    keybindings = {
      "super+v" = "paste_from_clipboard";
      "super+c" = "copy_or_interrupt";
      #"super+k" = "combine : clear_terminal scroll active : send_text normal,application \\x0c";
      "super+equal" = "increase_font_size";
      "super+minus" = "decrease_font_size";
      "super+shift+g" = "show_last_command_output";
      "super+ctrl+p" = "scroll_to_prompt -1";
      "super+ctrl+n" = "scroll_to_prompt 1";
    };
    settings = {
      enable_audio_bell = false;
      linux_display_server = "x11";
    };
    theme = "One Half Dark";
    shellIntegration.enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    tmux.enableShellIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      container = {
        disabled = true;
      };
    };
  };
}
