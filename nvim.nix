/*
* From Home-Manager config, treat neovim modules as source of truth and expose the final package.
* Wrap neovim in a simple bash script and leverage neovim remote. Inside nvim terminal, it will reuse the same nvim session
* Also creates a custom session socket when ran inside kitty terminal
*/
{ pkgs, self, neovim, lib, ... }:

let
  config = builtins.concatStringsSep "\n"
    (map builtins.readFile (lib.filesystem.listFilesRecursive ./modules/home-manager/neovim/lua)
    );
  customPlugins = builtins.attrValues (import ./modules/home-manager/neovim/plugins.nix {
    vimUtils =
      pkgs.vimUtils;
    fetchFromGitHub = pkgs.fetchFromGitHub;
    buildNeovimPluginFrom2Nix = pkgs.neovimUtils.buildNeovimPluginFrom2Nix;
  });

  myplugin = pkgs.vimUtils.buildVimPlugin {
    name = "myplugin";
    src =
      ./modules/home-manager/neovim/plugin/.;
  };

  nvim-remote = import ./nvim-remote.nix {
    writeShellScriptBin = pkgs.writeShellScriptBin;
  };

  fsharp-sitter = pkgs.fetchFromGitHub {
    owner = "ionide";
    repo = "tree-sitter-fsharp";
    rev = "dcbd07b8860fbde39f207dbc03b36a791986cd96";
    sha256 = "sha256-9YSywEoXxmLbyj3K888DbrHUBG4DrGTbYesW/SeDVvs=";
  };


  tt = pkgs.vimPlugins.nvim-treesitter.overrideAttrs ({
    src = /home/alialabbas/nvim-treesitter/.;
  });

  # TODO: a lot of this is just rtp stuff, setup a rtp and make sure it is what nvim sees
  myNvim = neovim.override {
    configure = {
      customRC =
        ''
          lua << EOF
        '' +
        config
        +
        ''
          EOF
        '';
      packages.myVimPackage = {
        start = with pkgs.vimPlugins; [
          # rather than source
          # pick a stage and add the files manually to the source
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

          nvim-treesitter-context
          comment-nvim
          nvim-lspconfig
          omnisharp-extended-lsp-nvim
          oil-nvim
          telescope-nvim
          vim-fugitive
          onedarkpro-nvim
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
          cmp-buffer

          # Documentation
          neogen
          vim-vsnip

          lualine-nvim
          fidget-nvim
          cmp-nvim-lsp-signature-help
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
          myplugin

          gitlinker-nvim
          alpha-nvim
          vim-rooter
          statuscol-nvim
        ] ++ customPlugins;

        opt = with pkgs.vimPlugins; [
          vim-nixhash
          vim-nix
          ansible-vim
          vim-helm
        ];
      };
    };
  };
in
{
  nvim = myNvim;
}
