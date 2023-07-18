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
    plugins = with pkgs.vimPlugins; [
      #(nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammar))
      nvim-treesitter.withAllGrammars
      nvim-treesitter-context
      comment-nvim
      refactoring-nvim
      nvim-lspconfig
      omnisharp-extended-lsp-nvim
      telescope-nvim
      vim-fugitive
      onehalf
      zenburn
      vim-nixhash
      vim-nix
      ansible-vim
      nvim-dap
      nvim-dap-ui
      nvim-nonicons
      nvim-web-devicons
      neotest
      cmp-nvim-lua
      cmp-git
      cmp-conventionalcommits
      cmp-dap
      toggleterm-nvim
      lualine-nvim
      cmp-nvim-lsp-signature-help
      telescope-ui-select-nvim
      dressing-nvim
      vim-helm
      nvim-navic
      statuscol-nvim
      gitsigns-nvim
      barbecue-nvim
      barbar-nvim
    ] ++ customPlugins;
    extraLuaConfig = builtins.readFile ../neovim/init.lua;
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

