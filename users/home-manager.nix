{ config, lib, pkgs, email, fullname, extraPkgs, extraBashrc, ... }:

{
  xdg.enable = true;

  home.stateVersion = "22.11";
  home.packages = [
    pkgs.bat
    pkgs.fd
    pkgs.fzf
    pkgs.htop
    pkgs.jq
    pkgs.ripgrep
    pkgs.rofi
    pkgs.tree
    pkgs.watch
    pkgs.zathura
    (with pkgs.dotnetCorePackages; combinePackages [ sdk_5_0 sdk_6_0 sdk_7_0 ])
    pkgs.yq
    pkgs.kind
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.go
    pkgs.gopls
    pkgs.omnisharp-roslyn
    pkgs.netcoredbg
    pkgs.rnix-lsp

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
    pkgs.git-url
  ] ++ extraPkgs;

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "vim";
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
    initExtra = builtins.readFile ./bashrc + extraBashrc;
    profileExtra = ''
      if [ -e /home/alialabbas/.nix-profile/etc/profile.d/nix.sh ]; then . /home/alialabbas/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
      '';

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

  programs.neovim = {
    enable = true;
    plugins = with pkgs; [
      # Neovim specific packages
      # include all grammers, no point in including only what I need right now
      (vimPlugins.nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
      vimPlugins.nvim-treesitter-context
      vimPlugins.comment-nvim
      vimPlugins.refactoring-nvim
      vimPlugins.nvim-lspconfig
      vimPlugins.omnisharp-extended-lsp-nvim
      vimPlugins.telescope-nvim
      # shared packages
      vimPlugins.vim-fugitive
      #customVim.omnisharp-vim # TODO: Figure out why Omnisharp won't work with vim-lsp
      customVim.vimspector
      vimPlugins.fzf-vim
      vimPlugins.vim-airline
      vimPlugins.vim-airline-themes
      vimPlugins.vim-gitgutter
      vimPlugins.onehalf
      vimPlugins.zenburn
      vimPlugins.vim-nixhash
      vimPlugins.vim-nix
      vimPlugins.ansible-vim
    ];
    extraConfig = builtins.readFile ./vimrc;
  };

  programs.vim = {
    enable = true;
    plugins = with pkgs; [
      vimPlugins.vim-fugitive
      customVim.omnisharp-vim # TODO: Figure out why Omnisharp won't work with vim-lsp
      customVim.vimspector
      customVim.vim-lsp-settings
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
