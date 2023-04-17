{ lib, pkgs, ... }:

with lib;
let
  customPlugins = builtins.attrValues (import ./plugins.nix {
    vimUtils = pkgs.vimUtils;
    fetchFromGitHub = pkgs.fetchFromGitHub;
    buildNeovimPluginFrom2Nix = pkgs.neovimUtils.buildNeovimPluginFrom2Nix;
  });
in
{
  programs.neovim = {
    enable = true;
    plugins = with pkgs; [
      (vimPlugins.nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
      vimPlugins.nvim-treesitter-context
      vimPlugins.comment-nvim
      vimPlugins.refactoring-nvim
      vimPlugins.nvim-lspconfig
      vimPlugins.omnisharp-extended-lsp-nvim
      vimPlugins.telescope-nvim
      vimPlugins.vim-fugitive
      vimPlugins.fzf-vim
      vimPlugins.vim-gitgutter
      vimPlugins.onehalf
      vimPlugins.zenburn
      vimPlugins.vim-nixhash
      vimPlugins.vim-nix
      vimPlugins.ansible-vim
      vimPlugins.nvim-dap
      vimPlugins.nvim-dap-ui
      vimPlugins.nvim-nonicons
      vimPlugins.nvim-web-devicons
      vimPlugins.neotest
      vimPlugins.cmp-nvim-lua
      vimPlugins.cmp-git
      vimPlugins.cmp-conventionalcommits
      vimPlugins.cmp-dap
      vimPlugins.toggleterm-nvim
      vimPlugins.lualine-nvim
    ] ++ customPlugins;
    extraConfig = builtins.readFile ../vim/vimrc;
  };

  home.packages = with pkgs; [
    netcoredbg
    gopls
    #rnix-lsp
    nixpkgs-fmt
    nil
    omnisharp-roslyn
    sumneko-lua-language-server
    yaml-language-server
  ];
}

