{ lib, pkgs, config, ... }:

with lib;
let
  customPlugins = builtins.attrValues (import ./plugins.nix {
    vimUtils =
      pkgs.vimUtils;
    fetchFromGitHub = pkgs.fetchFromGitHub;
    buildNeovimPluginFrom2Nix = pkgs.neovimUtils.buildNeovimPluginFrom2Nix;
  });

  myplugin = pkgs.vimUtils.buildVimPlugin {
    name = "myplugin";
    src =
      ./plugin/.;
  };

  nvim-remote = import ./nvim-remote.nix {
    writeShellScriptBin = pkgs.writeShellScriptBin;
    nvim = config.programs.neovim.finalPackage;
  };

in
{
  config = {
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
        telescope-file-browser-nvim
        vim-fugitive
        onehalf
        zenburn
        vim-nixhash
        vim-nix
        {
          plugin = ansible-vim;
          optional = true;
        }
        nvim-dap
        nvim-dap-ui
        nvim-dap-virtual-text
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

        # toggleterm-nvim
        lualine-nvim
        cmp-nvim-lsp-signature-help
        telescope-ui-select-nvim
        dressing-nvim

        {
          plugin = vim-helm;
          optional = true;
        }

        nvim-navic
        gitsigns-nvim
        barbecue-nvim
        dropbar-nvim
        tabby-nvim
        vim-bookmarks
        telescope-vim-bookmarks-nvim

        # Test Explorer
        neotest
        neotest-dotnet
        neotest-go
        myplugin

        indent-blankline-nvim
        gitlinker-nvim
        # dashboard-nvim
        alpha-nvim
        vim-rooter
        nui-nvim
        nvim-ufo
      ] ++ customPlugins;

      extraLuaConfig = builtins.readFile ../neovim/init.lua;

      # This is limited to language servers, debug adapters and some neovim only
      # tools
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
        pyright
        findutils.locate
      ];
    };

    # Neovim-remote is a wrapper to not open nested nvim sessions inside a vim terminal and also in a kitty session
    home.packages = [ nvim-remote ];
  };
}


