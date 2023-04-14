{ config, lib, pkgs, ... }:

with lib;
let
  customPlugins = pkgs.callPackage ./plugins.nix { };
in
{
  programs.vim = {
    enable = true;
    plugins = with pkgs;
      [
        vimPlugins.vim-fugitive
        customPlugins.omnisharp-vim # TODO: Omnisharp doesn't work with vim-lsp due to $metadata, see if it is possible to extend vim-lsp and potentially drop this
        vimPlugins.vimspector
        customPlugins.vim-lsp-settings
        vimPlugins.vim-lsp
        vimPlugins.context-vim
        vimPlugins.fzf-vim
        vimPlugins.vim-airline
        vimPlugins.vim-airline-themes
        vimPlugins.ale
        vimPlugins.asyncomplete-vim
        vimPlugins.vim-gitgutter
        vimPlugins.onehalf
        vimPlugins.zenburn
        vimPlugins.vim-nixhash
        vimPlugins.vim-nix
        vimPlugins.ansible-vim
      ];
    extraConfig = builtins.readFile ./vimrc;
  };

  # maybe these should be its own module imported at both vim and neovim
  home.packages = with pkgs; [
    netcoredbg
    gopls
    rnix-lsp
    omnisharp-roslyn
    delve
    gcc
  ];

}

