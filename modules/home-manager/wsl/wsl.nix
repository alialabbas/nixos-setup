{ pkgs, ... }:

{
  imports = [
    ../common.nix
    ../vim/vim.nix
    ../git/git.nix
    ../bash/bash.nix
    ../neovim/neovim.nix
  ];
  home.packages = [
    pkgs.wslu
  ];
}
