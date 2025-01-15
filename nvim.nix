/*
* From Home-Manager config, treat neovim modules as source of truth and expose the final package.
* Wrap neovim in a simple bash script and leverage neovim remote. Inside nvim terminal, it will reuse the same nvim session
* Also creates a custom session socket when ran inside kitty terminal
*/
{ pkgs, lib, ... }:

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

  # TODO: this need to be wrapped by myself with github
  # myplugin = pkgs.vimUtils.buildVimPlugin {
  #   name = "myplugin";
  #   src =
  #     ./modules/home-manager/neovim/plugin/.;
  # };

  nvim-remote = import ./nvim-remote.nix {
    writeShellScriptBin = pkgs.writeShellScriptBin;
  };

  fsharp-sitter = pkgs.fetchFromGitHub {
    owner = "ionide";
    repo = "tree-sitter-fsharp";
    rev = "dcbd07b8860fbde39f207dbc03b36a791986cd96";
    sha256 = "sha256-9YSywEoXxmLbyj3K888DbrHUBG4DrGTbYesW/SeDVvs=";
  };

  optionPlugins = with pkgs.vimPlugins; [
    vim-nixhash
    vim-nix
    ansible-vim
    vim-helm
  ];

  startPlugins = with pkgs.vimPlugins; [
    # I guess for this one we just download gcc and use TSInstall
    # Not a fan since that means I use different parser than what is in nix
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

    gitlinker-nvim
    alpha-nvim
    vim-rooter
    statuscol-nvim
  ] ++ customPlugins;

  # TODO: a lot of this is just rtp stuff, setup a rtp and make sure it is what nvim sees
  myNvim = pkgs.neovim.override {
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

  # LSP just download the binaries into a specific path
  # Some binaries won't be able to do that like omnisharp and other bits that assume dotnet or some other stuff installed
  # Will need to figure out a way around that
  # Also, need to figure out how
  # these are dependencies and making them optional should be safe since if I load some plugin by default will always
  # but there is an interesting case where I have a plugin in start but i consider it in start
  # plugin_dependencies - start will give us what is in the former and not defined in the latter
  # then we can load that
  # TODO: need more processing lib.lists.subtractLists
  plugin_dependencies = lib.lists.unique (lib.lists.flatten
    (builtins.filter (x: x != { })
      (map
        (drv:
          if builtins.hasAttr "dependencies" drv then
            map (inner: get_plugin_info inner) drv.dependencies
          else { })
        (optionPlugins ++ startPlugins)
      )
    )
  );
  get_plugin_info = olddrv:
    let
      drv = olddrv.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub { owner = old.src.owner; repo = old.src.repo; rev = old.src.rev; };
      });
    in
    { name = drv.src.repo; value = drv.src.url; };

  optionals = map (drv: get_plugin_info drv) optionPlugins;
  start = map
    (olddrv:
      # TODO: need an assert here for the url so we don't encounter non tar urls again
      # some plugins are fetched with git cli which makes .url point to the repo root rather than a tar
      # they don't need submodule in anyway and some just have empty submodules like oil.nvim
      # here we just want to force the same data and just disable fetchSubmodule flag from the original drv
      let
        drv = olddrv.overrideAttrs (old: {
          src = pkgs.fetchFromGitHub { owner = old.src.owner; repo = old.src.repo; rev = old.src.rev; };
        });
      in
      { name = drv.src.repo; value = drv.src.url; })
    startPlugins;
  # This only exist because I work in game development and sometimes I have to use windows host directly
  # when dealing with projects building only with msvc and don't generate a linux compatible compile_commands.json
  # Typically, all of this stuff is pre-installed in a linux wsl instance in windows land
  # config string will require some magic to work with echo and inlined in the script
  # Updates? how would that work?
  # Clean?
  # cfg = pkgs.writeTextFile { name = "init.lua"; text = config; };
  pwshScript = pkgs.writeTextFile {
    name = "install-nvim.ps1";
    text = ''
      $ErrorActionPreference = "Stop"
      Write-Host "Downloading Neovim ${myNvim.version}"
      Invoke-WebRequest https://github.com/neovim/neovim/releases/download/v${myNvim.version}/nvim-win64.msi -OutFile C:\temp\nvim-installer.msi

      Write-Host "Install Neovim"
      sudo msiexec /i nvim-installer.msi /quiet /qn /norestart

      Write-Host "Setting up runtime path"
      $RUNTIME_PATH="$env:APPDATA\..\local\nvim\pack\neovim_plugins"
      New-Item  $RUNTIME_PATH\start -ItemType "directory"
      New-Item  $RUNTIME_PATH\opt -ItemType "directory"

      ${builtins.foldl' (x: y: x + ''

      Write-Host "Installing Plugin ${y.name}"
      Invoke-WebRequest ${y.value} -OutFile $RUNTIME_PATH\start\${y.name}.tar
      New-Item  $RUNTIME_PATH\start\${y.name} -ItemType "directory"
      tar -zxf $RUNTIME_PATH\start\${y.name}.tar -C $RUNTIME_PATH/start/${y.name} --strip-components=1
      Remove-Item $RUNTIME_PATH\start\${y.name}.tar
      '') "" start}

      ${builtins.foldl' (x: y: x + ''

      Write-Host "Installing Plugin ${y.name}"
      Invoke-WebRequest ${y.value} -OutFile $RUNTIME_PATH\opt\${y.name}.tar
      New-Item  $RUNTIME_PATH\opt\${y.name} -ItemType "directory"
      tar -zxf $RUNTIME_PATH\opt\${y.name}.tar -C $RUNTIME_PATH\opt\${y.name} --strip-components=1
      Remove-Item $RUNTIME_PATH\opt\${y.name}.tar
      '') "" (optionals ++ plugin_dependencies)}
    '';
  };
in
{
  nvim = myNvim;
  opt = optionals;
  start = start;
  win-install-script = pwshScript;
  config = pkgs.writeTextFile { name = "init.lua"; text = config; };
  deps = lib.lists.unique plugin_dependencies;
}
