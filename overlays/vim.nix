
final: super:

{
  customVim = with final; {
    vim-misc = vimUtils.buildVimPlugin {
      name = "vim-misc";
      src = fetchFromGitHub {
        owner = "mitchellh";
        repo = "vim-misc";
        rev = "1205bd43e9b692d253572eddaf784977ae46f35b";
        sha256 = "1n6dsgppzgy95inq6mbqmphgbv7s97aslfmwdgasd8zy8grbd623";
      };
    };

    vim-nord = vimUtils.buildVimPlugin {
      name = "vim-nord";
      src = fetchFromGitHub {
        owner = "crispgm";
        repo = "nord-vim";
        rev = "cc5b0e9f472bdcbdaa701c94302796fb1e64e8d4";
        sha256 =  "0zb4a0xmk6q7ha8x0b28xb02vk390aypn82kcqy3ilv1l43pxly0";
      };
    };

    nvim-comment = vimUtils.buildVimPlugin {
      name = "nvim-comment";
      src = fetchFromGitHub {
        owner = "numToStr";
        repo = "Comment.nvim";
        rev = "79b356d00586ab9e6ffd1fbf732bf4f076c95d20";
        sha256 = "02f312dh0z71p0hfpx6y6a512p3i6w0bpd9yw51iyxcdkp9i40wl";
      };
    };

    nvim-treesitter-playground = vimUtils.buildVimPlugin {
      name = "nvim-treesitter-playground";
      src = fetchFromGitHub {
        owner = "nvim-treesitter";
        repo = "playground";
        rev = "787a7a8d4444e58467d6b3d4b88a497e7d494643";
        sha256 =  "1y4dwbs40qn942x0hd93yrk04yiphy73b45vcjrknmxq9szhvhk0";
      };
    };

    AfterColors = vimUtils.buildVimPlugin {
      name = "AfterColors";
      src = fetchFromGitHub {
        owner = "vim-scripts";
        repo = "AfterColors.vim";
        rev = "9936c26afbc35e6f92275e3f314a735b54ba1aaf";
        sha256 = "0j76g83zlxyikc41gn1gaj7pszr37m7xzl8i9wkfk6ylhcmjp2xi";
      };
    };

    dracula = vimUtils.buildVimPlugin {
      name = "dracula";
      src = fetchFromGitHub {
        owner = "dracula";
        repo = "vim";
        rev = "d7723a842a6cfa2f62cf85530ab66eb418521dc2";
        sha256 =  "1qzil8rwpdzf64gq63ds0cf509ldam77l3fz02g1mia5dry75r02";
      };
    };
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
    vimspector = vimUtils.buildVimPluginFrom2Nix rec {
      gadgetFile = pkgs.writeTextFile { name = ".gadgets.json"; text = builtins.readFile ./gadgets.json; };
      netcoredbg = pkgs.netcoredbg;
      pname = "vimspector";
      version = "2022-05-01";
      src = fetchFromGitHub {
        owner = "puremourning";
        repo = "vimspector";
        rev = "960f0444d21ebb20303e1796e4b478df042c3bd3";
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
};
}

