{ vimUtils, fetchFromGitHub, buildNeovimPluginFrom2Nix }:

{
  nvim-treesitter-playground = vimUtils.buildVimPlugin {
    name = "nvim-treesitter-playground";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "playground";
      rev = "787a7a8d4444e58467d6b3d4b88a497e7d494643";
      sha256 = "1y4dwbs40qn942x0hd93yrk04yiphy73b45vcjrknmxq9szhvhk0";
    };
  };
  neotest-dotnet = vimUtils.buildVimPlugin {
    name = "neotest-dotnet";
    src = fetchFromGitHub {
      owner = "Issafalcon";
      repo = "neotest-dotnet";
      rev = "cb0e6f580e4877034a76a02c3e8aed75dcbc8c48";
      sha256 = "sha256-otLtNzWhBNcwll9RTI2YjAGw8Avz5dnUc7cKHbPUFXQ=";
    };
  };
  neotest-go = vimUtils.buildVimPlugin {
    name = "neotest-go";
    src = fetchFromGitHub {
      owner = "nvim-neotest";
      repo = "neotest-go";
      rev = "756edf3dddcb3b430110f9582e10b7e730428341";
      sha256 = "sha256-McofCzxPFksPqrT+Pka9syOgLLwYci3k1EQGx4JzjQ4=";
    };
  };
  sidebar-nvim = vimUtils.buildVimPlugin {
    name = "sidebar-nvim";
    src = fetchFromGitHub {
      owner = "sidebar-nvim";
      repo = "sidebar.nvim";
      rev = "990ce5f562c9125283ccac5473235b1a56fea6dc";
      sha256 = "sha256-/6q/W7fWXlJ2B9o4v+0gg2QjhzRC/Iws+Ez6yyL1bqI=";
    };
  };
  nvim-cmp-lsp = vimUtils.buildVimPlugin {
    name = "nvim-cmp-lsp";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp";
      rev = "0e6b2ed705ddcff9738ec4ea838141654f12eeef";
      sha256 = "sha256-DxpcPTBlvVP88PDoTheLV2fC76EXDqS2UpM5mAfj/D4=";
    };
  };
  nvim-cmp = buildNeovimPluginFrom2Nix {
    pname = "nvim-cmp";
    version = "2023-03-17";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "777450fd0ae289463a14481673e26246b5e38bf2";
      sha256 = "sha256-CoHGIiZrhRAHZ/Er0JSQMapI7jwllNF5OysLlx2QEik=";
    };
  };
  cmp-vsnip = vimUtils.buildVimPlugin {
    name = "cmp-vsnip";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-vsnip";
      rev = "989a8a73c44e926199bfd05fa7a516d51f2d2752";
      sha256 = "sha256-ehPnvGle7YrECn76YlSY/2V7Zeq56JGlmZPlwgz2FdE=";
    };
  };
  vim-vsnip = vimUtils.buildVimPlugin {
    name = "vim-vsnip";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "vim-vsnip";
      rev = "7753ba9c10429c29d25abfd11b4c60b76718c438";
      sha256 = "sha256-ehPnvGle7YrECn76YlSY/2V7Zeq56JGlmZPlwgz2FdE=";
    };
  };
  neogen = vimUtils.buildVimPlugin {
    name = "neogen";
    src = fetchFromGitHub {
      owner = "danymat";
      repo = "neogen";
      rev = "9c17225aac94bdbf93baf16e1b2d2c6dcffb0901";
      sha256 = "sha256-k/PLgqNyhY5OCRpdcul/YBKLI8bs8Ukaj8y3C9YEjN4=";
    };
  };
}

