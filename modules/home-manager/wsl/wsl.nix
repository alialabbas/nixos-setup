{ pkgs, lib, ... }:

{
  imports = [
    ../common.nix
    ../vim/vim.nix
    ../git/git.nix
    ../bash/bash.nix
    ../neovim/neovim.nix
  ];
}
