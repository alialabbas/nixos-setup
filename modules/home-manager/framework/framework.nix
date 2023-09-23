{ pkgs, lib, ... }:

{
  imports = [
    ../common.nix
    ../vim/vim.nix
    ../git/git.nix
    ../bash/bash.nix
    ../neovim/neovim.nix
  ];

  home.packages = with pkgs; [
    rofi
    firefox
  ];

  xdg.configFile."i3/config".text = builtins.readFile ../../../dotfiles/i3;
  xdg.configFile."rofi/config.rasi".text = builtins.readFile ../../../dotfiles/rofi;

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
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
  };

  xresources.extraConfig = builtins.readFile ../../../dotfiles/Xresources;

}
