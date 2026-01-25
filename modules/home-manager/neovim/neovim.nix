{ lib, pkgs, config, ... }:

let
  customPlugins = builtins.attrValues (import ./plugins.nix {
    vimUtils =
      pkgs.vimUtils;
    fetchFromGitHub = pkgs.fetchFromGitHub;
    buildNeovimPluginFrom2Nix = pkgs.neovimUtils.buildNeovimPluginFrom2Nix;
  });

  # TODO: probably should just be a wrapper and just call nvim all the time
  nvim-remote = import ./nvim-remote.nix {
    writeShellScriptBin = pkgs.writeShellScriptBin;
  };

  # Bundle our configuration (lua, lsp, plugin) into a derivation
  # This makes it a "plugin" in Nix terms, adding it to the runtimepath
  # ensuring a fully self-contained Neovim build.
  # nvim-config = pkgs.runCommand "nvim-config" { } ''
  #   mkdir -p $out
  #   ln -s ${./lua} $out/lua
  #   ln -s ${./lsp} $out/lsp
  #   ln -s ${./plugin} $out/plugin
  # '';

  fsharp-sitter = pkgs.fetchFromGitHub {
    owner = "ionide";
    repo = "tree-sitter-fsharp";
    rev = "dcbd07b8860fbde39f207dbc03b36a791986cd96";
    sha256 = "sha256-9YSywEoXxmLbyj3K888DbrHUBG4DrGTbYesW/SeDVvs=";
  };
in
{
  config = {
    programs.neovim = {
      enable = true;

      # Load our main init module, which is found because nvim-config is in the runtimepath
      extraLuaConfig = ''
        require("init")
      '';

      plugins = with pkgs.vimPlugins; [
        ((nvim-treesitter.withPlugins (_: nvim-treesitter.allGrammars ++ [
          (pkgs.tree-sitter.buildGrammar {
            language = "fsharp";
            version = "dcbd07b";
            location = "fsharp";
            src = fsharp-sitter;
          })
        ])).overrideAttrs {
          postInstall = ''
            mkdir -p $out/queries/fsharp
            ls ${fsharp-sitter}/queries/*.scm
            cp  ${fsharp-sitter}/queries/*.scm $out/queries/fsharp/
            ls $out/queries/fsharp
          '';
        })

        nvim-lspconfig
        oil-nvim
        telescope-nvim
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
        {
          plugin = vim-nickel;
          optional = true;
        }
        {
          plugin = vim-helm;
          optional = true;
        }

        nvim-dap
        nvim-dap-view
        nvim-web-devicons
        nvim-nonicons

        # AutoCompletion
        cmp-nvim-lua
        cmp-git
        cmp-conventionalcommits
        cmp-dap
        nvim-cmp
        cmp-nvim-lsp
        cmp-vsnip
        cmp-path
        cmp-buffer
        vim-vsnip
        cmp-nvim-lsp-signature-help

        # Documentation
        neogen

        lualine-nvim
        fidget-nvim
        telescope-ui-select-nvim
        dressing-nvim


        gitsigns-nvim
        dropbar-nvim
        tabby-nvim
        vim-bookmarks
        telescope-vim-bookmarks-nvim

        # Test Explorer
        neotest
        neotest-dotnet
        neotest-go

        gitlinker-nvim
        alpha-nvim
        statuscol-nvim

        {
          plugin = markview-nvim;
          optional = true;
        }
      ] ++ customPlugins;

      extraPackages = with pkgs; [
        helm-ls
        jsonnet-language-server
        netcoredbg
        gopls
        delve
        nixpkgs-fmt
        omnisharp-roslyn
        lua-language-server
        emmylua-ls
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
        roslyn-ls
        nvim-remote
      ];
    };

    # Neovim-remote is a wrapper to not open nested nvim sessions inside a vim terminal and also in a kitty session
    home.packages = [ nvim-remote pkgs.neovide ];

    xdg.configFile."nvim/lua" = {
      source = ./lua;
      recursive = true;
    };

    xdg.configFile."nvim/lsp" = {
      source = ./lsp;
      recursive = true;
    };

    xdg.configFile."nvim/after" = {
      source = ./after;
      recursive = true;
    };

    xdg.configFile."nvim/plugin" = {
      source = ./plugin;
      recursive = true;
    };
  };
}
