{ pkgs, vimUtils, fetchFromGitHub, netcoredbg }:

{
  # Pinned to an older version due to a bug with OmniSharpDebugProject not working anymore
  omnisharp-vim = vimUtils.buildVimPlugin {
    name = "omnisharp-vim";
    src = fetchFromGitHub {
      owner = "OmniSharp";
      repo = "omnisharp-vim";
      rev = "2b664e3d33b3174ca30c05b173e97331b74ec075";
      sha256 = "UJhV9rbefNWqbc3AB+jW/+zNx7mhcURGNN6lg4rvS9g=";
    };
  };

  vim-lsp-settings = vimUtils.buildVimPluginFrom2Nix {
    name = "vim-lsp-settings";
    src = fetchFromGitHub {
      owner = "mattn";
      repo = "vim-lsp-settings";
      rev = "75bd847e1ad342d77c715601c68c27be31bae257";
      sha256 = "RRLmbKnPoz4iAIYner8q+rKBgow7MVSrItIfJW/+LXA=";
    };
  };
  # building custom vimpsector instead of the one in nixpkgs to allow me to add gadgets to the default
  # vimspector path... Not sure if it is a bug but when vimspector launch without configuration it can only
  # use the defaults adapter  defined in .gadgets.json and I have to tell it where to find them in the next store
  # TODO: if this would stay as is, at least figure out how to setup the runtime dependencies correctly
  # TODO: figuire out why vimspector adapters don't get configured correctly when using vimrc g:vimspector_adapters
  # As of now this makes it difficult to properly configure it with adapters on the fly like vim-lsp-settings
  vimspector = vimUtils.buildVimPluginFrom2Nix rec {
    gadgetFile = pkgs.writeTextFile { name = ".gadgets.json"; text = builtins.readFile ./gadgets.json; };
    netcoredbg = pkgs.netcoredbg;
    buildInputs = [ pkgs.netcoredbg ];
    pname = "vimspector";
    version = "2023-05-21";
    src = fetchFromGitHub {
      owner = "puremourning";
      repo = "vimspector";
      rev = "93fd1058697394789b413ae70b19428533ebf7b1";
      sha256 = "0sx2awi2b22j9wdyi8m1k261qlfj19i2xs93g5lb24lfb53rarmi";
      fetchSubmodules = true;
    };
    postInstall = ''
      mkdir $out/gadgets
      mkdir $out/gadgets/linux
      mkdir $out/gadgets/linux/netcoredbg
      ln -s ${netcoredbg}/bin/netcoredbg $out/gadgets/linux/netcoredbg/netcoredbg
      ln -s ${gadgetFile} $out/gadgets/linux/.gadgets.json
    '';
  };
}

