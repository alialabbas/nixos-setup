{ pkgs, vimUtils, fetchFromGitHub, netcoredbg }:

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
}

