{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.neovim;
  customPlugins = pkgs.callPackage ./plugins.nix { };
in
{
  options.modules.neovim = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };

    plugins = mkOption {
      default = [ ];
      type = with types; listOf package;
      example = literalExpression ''
        with pkgs.vimPlugins; [
          vim-sensible
        ]
      '';
      description = "List of vim plugins you want to add on top of the packaged version";
    };


    vimrc = mkOption {
      default = "";
      type = types.lines;
      example = ''
        set nocompatible
        set nobackup
      '';
      description = "Additional runtime configuration for your vimrc";
    };
  };

  config = mkIf cfg.enable {
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
      ] ++ cfg.plugins;
      extraConfig = (import ../vim/vimrc.nix { inherit pkgs; }); # TODO: break up the common and move vim and neovim specific config to specific files
    };
  };
}

