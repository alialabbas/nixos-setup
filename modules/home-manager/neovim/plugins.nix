{ vimUtils, fetchFromGitHub, buildNeovimPluginFrom2Nix }:

{
  yaml-companion-nvim = vimUtils.buildVimPlugin {
    pname = "yaml-companion-nvim";
    version = "2024-05-01";
    src = fetchFromGitHub {
      owner = "someone-stole-my-name";
      repo = "yaml-companion.nvim";
      rev = "4de1e1546abc461f62dee02fcac6a02debd6eb9e";
      sha256 = "sha256-BmX7hyiIMQfcoUl09Y794HrSDq+cj93T+Z5u3e5wqLc=";
    };
  };

  bookmarks-nvim = vimUtils.buildVimPlugin {
    pname = "bookmarks-nvim";
    version = "2024-05-09";
    src = fetchFromGitHub {
      owner = "tomasky";
      repo = "bookmarks.nvim";
      rev = "0540d52ba64d0ec7677ec1ef14b3624c95a2aaba";
      sha256 = "sha256-C6ug5GT1endIOYIomSdBwH9wBUPvnF7hkMNL5+jQ9RA=";
    };
  };

  telescope-repo-nvim = vimUtils.buildVimPlugin {
    pname = "telescope-repo-nvim";
    version = "2024-04-25";
    src = fetchFromGitHub {
      owner = "cljoly";
      repo = "telescope-repo.nvim";
      rev = "36720ed0ac724fc7527a6a4cf920e13164039400";
      sha256 = "sha256-m9icWnwM4Wl1PW2dLaQne5PaKbjfVEEzWxbETJJSUxw=";
    };
    meta.homepage = "https://github.com/cljoly/telescope-repo.nvim";
  };

  possession-nvim = vimUtils.buildVimPlugin {
    pname = "possession-nvim";
    version = "2024-06-11";
    src = fetchFromGitHub {
      owner = "jedrzejboczar";
      repo = "possession.nvim";
      rev = "09ce7c6cc55923eaf9a8002bb0db3902c639a2ce";
      sha256 = "sha256-5Nz1kS72e7V99A3+B2vjzo/qXthbqy5lUzl07flug7Y=";
    };
    meta.homepage = "https://github.com/cljoly/telescope-repo.nvim";
  };
}
