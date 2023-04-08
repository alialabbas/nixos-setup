{ config, lib, pkgs, ... }:

let
  myPkgs = lib.attrValues (import ../../lib/pkgsBuilder.nix { inherit pkgs lib; });
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
  ] ++ myPkgs;

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "vim";
    PAGER = "less -FirSwX";
    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
  };

  programs.readline = {
    enable = true;
    extraConfig = builtins.readFile ../../dotfiles/inputrc;
  };

  programs.tmux = {
    enable = true;
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
    extraConfig = builtins.readFile ../../dotfiles/kitty;
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
