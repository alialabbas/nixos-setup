{ config, lib, pkgs, ... }:

with lib;
let
  customPlugins = pkgs.callPackage ./plugins.nix { };
in
{
  programs.neovim = {
    enable = true;
    plugins = with pkgs; [
      (vimPlugins.nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
      vimPlugins.nvim-treesitter-context
      customPlugins.nvim-treesitter-playground
      vimPlugins.comment-nvim
      vimPlugins.refactoring-nvim
      vimPlugins.nvim-lspconfig
      vimPlugins.omnisharp-extended-lsp-nvim
      vimPlugins.telescope-nvim
      vimPlugins.vim-fugitive
      vimPlugins.fzf-vim
      vimPlugins.vim-airline
      vimPlugins.vim-airline-themes
      vimPlugins.vim-gitgutter
      vimPlugins.onehalf
      vimPlugins.zenburn
      vimPlugins.vim-nixhash
      vimPlugins.vim-nix
      vimPlugins.ansible-vim
    ];
    extraConfig = builtins.readFile ../vim/vimrc;
  };

  home.packages = with pkgs; [
    netcoredbg
    gopls
    rnix-lsp
    omnisharp-roslyn
  ];
}

