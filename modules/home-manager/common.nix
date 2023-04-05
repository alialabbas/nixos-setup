{ config, lib, pkgs, ... }:

let
  myPkgs = lib.attrValues (import ../../lib/pkgsBuilder.nix { inherit pkgs lib; });
in
{
  xdg.enable = true;

  home.stateVersion = "22.11";

  programs.home-manager.enable = true;

  home.packages = [
    pkgs.bat
    pkgs.fd
    pkgs.htop
    pkgs.jq
    pkgs.ripgrep
    pkgs.tree
    pkgs.watch
    (with pkgs.dotnetCorePackages; combinePackages [ sdk_6_0 sdk_7_0 ]) # TODO: move dotnet and languages outside of this module into an inlined one inside flake.nix to make it easy to change these dependencies later on
    pkgs.go
    pkgs.yq
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
    extraConfig = builtins.readFile ../../users/inputrc;
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
    extraConfig = builtins.readFile ../../users/kitty;
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
