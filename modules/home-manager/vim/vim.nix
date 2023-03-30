{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.vim;
  customPlugins = pkgs.callPackage ./plugins.nix { };
in
{
  options.modules.vim = {
    enable = mkOption {
      default = false;
      type = types.bool;
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
    programs.vim = {
      enable = true;
      plugins = with pkgs;
        [
          vimPlugins.vim-fugitive
          customPlugins.omnisharp-vim # TODO: Figure out why Omnisharp won't work with vim-lsp
          customPlugins.vimspector
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
      extraConfig = (import ./vimrc.nix) { inherit pkgs; } + cfg.vimrc;
    };
  };
}

