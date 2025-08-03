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
    doCheck = false;
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
      rev = "8fb21fabae4e5ffd98386e1b11e9d9d429633bdf";
      sha256 = "sha256-RJ+6qWBLJDhLqkjuV/ESescWUvmEWkVN9QnBLiLVpbs=";
    };
    doCheck = false;
    meta.homepage = "https://github.com/cljoly/telescope-repo.nvim";
  };
}
