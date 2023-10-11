{ lib, pkgs, ... }:

with lib;
let
  customPlugins = builtins.attrValues (import ./plugins.nix {
    vimUtils = pkgs.vimUtils;
    fetchFromGitHub = pkgs.fetchFromGitHub;
    buildNeovimPluginFrom2Nix = pkgs.neovimUtils.buildNeovimPluginFrom2Nix;
  });

  myplugin = pkgs.vimUtils.buildVimPlugin {
    name = "myplugin";
    src = ./plugin/.;
  };
in
{
  programs.neovim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
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

      # AutoCompletion
      cmp-nvim-lua
      cmp-git
      cmp-conventionalcommits
      cmp-dap
      nvim-cmp
      cmp-nvim-lsp
      cmp-vsnip
      cmp-path

      # Documentation
      neogen
      vim-vsnip
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
      vim-bookmarks
      telescope-vim-bookmarks-nvim

      # Test Explorer
      neotest
      neotest-dotnet
      neotest-go
      myplugin
    ] ++ customPlugins;

    extraLuaConfig = builtins.readFile ../neovim/init.lua;

    # This is limited to language servers, debug adapters and some neovim only tools
    extraPackages = with pkgs;[
      helm-ls
      jsonnet-language-server
      netcoredbg
      gopls
      delve
      nixpkgs-fmt
      nil
      omnisharp-roslyn
      sumneko-lua-language-server
      yaml-language-server
    ];
  };
}

