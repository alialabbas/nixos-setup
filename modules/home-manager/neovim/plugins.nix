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

  sidebar-nvim = vimUtils.buildVimPlugin {
    name = "sidebar-nvim";
    src = fetchFromGitHub {
      owner = "sidebar-nvim";
      repo = "sidebar.nvim";
      rev = "990ce5f562c9125283ccac5473235b1a56fea6dc";
      sha256 = "sha256-/6q/W7fWXlJ2B9o4v+0gg2QjhzRC/Iws+Ez6yyL1bqI=";
    };
  };

  yaml-companion-nvim = vimUtils.buildVimPluginFrom2Nix {
    pname = "yaml-companion-nvim";
    version = "2023-03-03";
    src = fetchFromGitHub {
      owner = "someone-stole-my-name";
      repo = "yaml-companion.nvim";
      rev = "4de1e1546abc461f62dee02fcac6a02debd6eb9e";
      sha256 = "sha256-BmX7hyiIMQfcoUl09Y794HrSDq+cj93T+Z5u3e5wqLc=";
    };
  };

  bookmarks-nvim = vimUtils.buildVimPluginFrom2Nix {
    pname = "bookmarks-nvim";
    version = "2023-07-06";
    src = fetchFromGitHub {
      owner = "tomasky";
      repo = "bookmarks.nvim";
      rev = "e51023c89512aec01158be69510547e54b1a4948";
      sha256 = "sha256-C9GM2M3ljCNaarrOLqwp9T6XJWNtIxwLCwHXyym3w8E=";
    };
  };
}
