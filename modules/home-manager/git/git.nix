{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.git;
in
{
  options.modules.git = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };

    username = mkOption {
      default = null;
      type = types.nullOr types.str;
      example = "FirstName LastName";
      description = ''
        Your username in git config, equivelant to running git config -global user.name firstname lastname
      '';
    };

    email = mkOption {
      default = null;
      type = types.nullOr types.str;
      example = "email@host.com";
      description = ''
        email associated wit git, git config -global user.email email.com
        '';
      };

    aliases = mkOption {
      default = { };
      type = types.attrs;
      example = { diffnames = "git diff --nameonly"; };
      description = ''
        Attribute sets for additional aliases that you want to add to your custom settings
      '';
    };
    extraConfig = mkOption {
      default = { };
      type = types.attrs;
      example = {
        core = { whitespace = "trailing-space,space-before-tab"; };
      };
    };

    ignores = mkOption {
      default = [ ];
      type = types.listOf types.str;
      example = [ "fileToIgnore" ];
      description = ''
        list of files to be globally ignored
      '';
    };

  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = cfg.username;
      userEmail = cfg.email;
      aliases = {
        prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        root = "rev-parse --show-toplevel";
      } // cfg.aliases;
      extraConfig = {
        branch.autosetuprebase = "always";
        color.ui = true;
        core.askPass = "";
        credential.helper = "store";
        push.default = "tracking";
        init.defaultBranch = "main";
        diff.tool = "vimdiff";
        difftool.prompt = false;
      };
      ignores = [ "*~" "*.swp" "result" "bin/" "obj/" ] ++ cfg.ignores;
    };
  };
}

