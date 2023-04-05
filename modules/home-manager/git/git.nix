{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;
    aliases = {
      prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      root = "rev-parse --show-toplevel";
    };
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
    ignores = [ "*~" "*.swp" "result" "bin/" "obj/" ];
  };
}

