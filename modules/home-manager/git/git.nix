{ config, lib, pkgs, ... }:

let
  git-clone-to = pkgs.writeShellScript "git-clone-to" ''
    URL=$1
    if [ -z "$URL" ]; then
      echo "Usage: git clone-to <url>"
      exit 1
    fi

    # Remove protocol (http://, https://, ssh://)
    CLEAN_URL=''${URL#*://}
    # Remove user (git@)
    CLEAN_URL=''${CLEAN_URL#*@}
    # Replace : with / (for SSH style git@host:path)
    CLEAN_URL=''${CLEAN_URL//:/\/}
    # Remove .git suffix
    CLEAN_URL=''${CLEAN_URL%.git}

    TARGET_DIR="$HOME/repos/$CLEAN_URL"

    if [ -d "$TARGET_DIR" ]; then
      echo "Directory $TARGET_DIR already exists."
      exit 1
    fi

    mkdir -p "$(dirname "$TARGET_DIR")"
    ${pkgs.git}/bin/git clone "$URL" "$TARGET_DIR"
  '';
in
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Ali Alabbas";
        email = "ali.n.alabbas@gmail.com";
      };
      alias = {
        prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        root = "rev-parse --show-toplevel";
        diffk = "difftool --tool=kitty --no-symlinks --dir-diff";
        vimdiff = "!git --no-pager  difftool --tool=nvimdiff --dir-diff";
        clone-to = "!${git-clone-to}";
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
    };
    ignores = [ "*~" "*.swp" "result" "bin/" "obj/" ];
  };
}

