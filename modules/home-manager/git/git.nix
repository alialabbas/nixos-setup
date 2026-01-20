{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Ali Alabbas";
        email = "ali.n.alabbas@gmail.com";
      };
      aliases = {
        prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        root = "rev-parse --show-toplevel";
        diffk = "difftool --tool=kitty --no-symlinks --dir-diff";
        vimdiff = "!git --no-pager  difftool --tool=nvimdiff --dir-diff";
      };

      branch.autosetuprebase = "always";
      color.ui = true;
      core.askPass = "";
      credential.helper = "store";
      push.default = "tracking";
      init.defaultBranch = "main";
      pager.difftool = true;
      diff.tool = "difftastic";
      difftool.prompt = false;
      "difftool \"difftastic\"".cmd = "${pkgs.difftastic}/bin/difft $LOCAL $REMOTE";
      "difftool \"kitty\"".cmd = "kitten diff $LOCAL $REMOTE";
      "difftool \"kitty.gui\"".cmd = "kitten diff $LOCAL $REMOTE ";
      "mergetool \"nvimerge\"".cmd = "nvim -d $BASE $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
      "difftool \"nvimdiff\"".cmd = "nvim -c \"Diff $LOCAL $REMOTE\"";
      # extraConfig = {
      #   branch.autosetuprebase = "always";
      #   color.ui = true;
      #   core.askPass = "";
      #   credential.helper = "store";
      #   push.default = "tracking";
      #   init.defaultBranch = "main";
      #   pager.difftool = true;
      #   diff.tool = "difftastic";
      #   difftool.prompt = false;
      #   "difftool \"difftastic\"".cmd = "${pkgs.difftastic}/bin/difft $LOCAL $REMOTE";
      #   "difftool \"kitty\"".cmd = "kitten diff $LOCAL $REMOTE";
      #   "difftool \"kitty.gui\"".cmd = "kitten diff $LOCAL $REMOTE ";
      #   "mergetool \"nvimerge\"".cmd = "nvim -d $BASE $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
      #   "difftool \"nvimdiff\"".cmd = "nvim -c \"Diff $LOCAL $REMOTE\"";
      # };
    };
    ignores = [ "*~" "*.swp" "result" "bin/" "obj/" ];
  };
}

