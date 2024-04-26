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
    config = config.programs.neovim.extraLuaConfig;
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
        nvim-lspconfig
        omnisharp-extended-lsp-nvim
        telescope-nvim
        telescope-file-browser-nvim
        vim-fugitive
        onedarkpro-nvim
        {
          plugin = vim-nixhash;
          optional = true;
        }
        {
          plugin = vim-nix;
          optional = true;
        }
        {
          plugin = ansible-vim;
          optional = true;
        }
        vim-nickel

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

        lualine-nvim
        fidget-nvim
        cmp-nvim-lsp-signature-help
        telescope-ui-select-nvim
        dressing-nvim

        {
          plugin = vim-helm;
          optional = true;
        }

        gitsigns-nvim
        dropbar-nvim
        tabby-nvim
        vim-bookmarks
        telescope-vim-bookmarks-nvim

        # Test Explorer
        neotest
        neotest-dotnet
        neotest-go
        myplugin

        gitlinker-nvim
        alpha-nvim
        vim-rooter
      ] ++ customPlugins;

      extraLuaConfig = builtins.concatStringsSep "\n"
        (map builtins.readFile (lib.filesystem.listFilesRecursive ./lua)
        );

      # This is limited to language servers, debug adapters and some neovim only tools
      extraPackages = with pkgs; [
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
        nodePackages.bash-language-server
        efm-langserver
        shellcheck
        shfmt
        jq
        markdownlint-cli
        hadolint
        nixd
        nls
      ];
    };

    # Neovim-remote is a wrapper to not open nested nvim sessions inside a vim terminal and also in a kitty session
    home.packages = [ nvim-remote ];
  };
}
