{ config, lib, pkgs, email, fullname, extraPkgs,... }:

{
  xdg.enable = true;

  home.packages = [
    pkgs.bat
    pkgs.fd
    pkgs.firefox
    pkgs.fzf
    pkgs.htop
    pkgs.jq
    pkgs.ripgrep
    pkgs.rofi
    pkgs.tree
    pkgs.watch
    pkgs.zathura
    pkgs.dotnet-sdk
    pkgs.yq
    pkgs.kind
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.go
    pkgs.gopls
    pkgs.omnisharp-roslyn
    pkgs.python39Packages.python-lsp-server
    pkgs.python39

    pkgs.netcoredbg
    pkgs.nodePackages.vim-language-server
    # overlays helper scripts from ../../overlays/k8-helpers.nix
    pkgs.kconfig
    pkgs.kforward
    pkgs.klogs
    pkgs.knamespace
    pkgs.krepl
    pkgs.kexec
    pkgs.hreleases
    pkgs.hdelns
    pkgs.fzf-repl
  ] ++ extraPkgs;

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
  };

  home.file.".inputrc".source = ./inputrc;

  xdg.configFile."i3/config".text = builtins.readFile ./i3;
  xdg.configFile."rofi/config.rasi".text = builtins.readFile ./rofi;

  programs.bash = {
    enable = true;
    shellOptions = [];
    historyControl = [ "ignoredups" "ignorespace" ];
    initExtra = builtins.readFile ./bashrc;

    shellAliases = {
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gdiff = "git diff";
      gl = "git prettylog";
      gp = "git push";
      gs = "git status";
      gt = "git tag";
    };
  };

  programs.git = {
    enable = true;
    userName = fullname;
    userEmail = email;
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

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    secureSocket = false;
    plugins = with pkgs.tmuxPlugins; [
      sidebar
      pain-control
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-show-powerline true
          set -g @dracula-plugins "cpu-usage ram-usage weather time"
          set -g @dracula-show-fahrenheit false
        '';
      }
    ];

    extraConfig = ''
      set -ga terminal-overrides ",*256col*:Tc"
      set -g @dracula-show-fahrenheit false
      bind -n C-k send-keys "clear"\; send-keys "Enter"
    '';
  };

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./kitty;
  };

  programs.i3status = {
    enable = true;

    general = {
      colors = true;
      color_good = "#8C9440";
      color_bad = "#A54242";
      color_degraded = "#DE935F";
    };

    modules = {
      ipv6.enable = false;
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
  };

  programs.vim = {
    enable = true;
    plugins = with pkgs; [
      vimPlugins.vim-fugitive
      customVim.omnisharp-vim # TODO: Figure out why Omnisharp won't work with vim-lsp
      customVim.vimspector
      vimPlugins.vim-lsp
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
    ];
    extraConfig = builtins.readFile ./vimrc;
  };

  programs.fzf = {
      enable = true;
      enableBashIntegration = true;
      tmux.enableShellIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };

  xresources.extraConfig = builtins.readFile ./Xresources;

  # Make cursor not tiny on HiDPI screens
  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 128;
    x11.enable = true;
  };
}
