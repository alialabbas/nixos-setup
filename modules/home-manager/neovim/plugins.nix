{ vimUtils, fetchFromGitHub, buildNeovimPluginFrom2Nix }:

{
  yaml-companion-nvim = vimUtils.buildVimPlugin {
    pname = "yaml-companion-nvim";
    version = "2023-03-03";
    src = fetchFromGitHub {
      owner = "someone-stole-my-name";
      repo = "yaml-companion.nvim";
      rev = "4de1e1546abc461f62dee02fcac6a02debd6eb9e";
      sha256 = "sha256-BmX7hyiIMQfcoUl09Y794HrSDq+cj93T+Z5u3e5wqLc=";
    };
  };

  bookmarks-nvim = vimUtils.buildVimPlugin {
    pname = "bookmarks-nvim";
    version = "2023-07-06";
    src = fetchFromGitHub {
      owner = "tomasky";
      repo = "bookmarks.nvim";
      rev = "e51023c89512aec01158be69510547e54b1a4948";
      sha256 = "sha256-C9GM2M3ljCNaarrOLqwp9T6XJWNtIxwLCwHXyym3w8E=";
    };
  };

  smartcolumn-nvim = vimUtils.buildVimPlugin {
    pname = "smartcolumn-nvim";
    version = "2023-09-12";
    src = fetchFromGitHub {
      owner = "m4xshen";
      repo = "smartcolumn.nvim";
      rev = "c6abf3917fcec487c7475e208ae37f5788af5b04";
      sha256 = "sha256-O9lPx4WVtiH8tCXVGtNHpcNDDIC+IdcZl8ielDD+rcY=";
    };
  };

  # REMOVE: once the plugin merge the dev branch for nvim 0.10
  statuscol-nvim = vimUtils.buildVimPlugin {
    pname = "statuscol-nvim";
    version = "2023-12-16";
    src = fetchFromGitHub {
      owner = "luukvbaal";
      repo = "statuscol.nvim";
      rev = "ef3617d0c8cfaa29f7bcdaa8b7cc35df2a409bae";
      sha256 = "sha256-Rl0VlsExASyx0+Le7VsY4aVQ+LqFWknZSFh40qGWEHI=";
    };
    meta.homepage = "https://github.com/luukvbaal/statuscol/";
  };

  telescope-repo-nvim = vimUtils.buildVimPlugin {
    pname = "telescope-repo-nvim";
    version = "2023-10-25";
    src = fetchFromGitHub {
      owner = "cljoly";
      repo = "telescope-repo.nvim";
      rev = "e17462610fb936bc8a8cc12a249c3252156dd6f7";
      sha256 = "sha256-ZpxYhLWsDjhAS8x127h+kWOlUO9EntIP4ICibxp0Kxo=";
    };
    meta.homepage = "https://github.com/cljoly/telescope-repo.nvim";
  };

  possession-nvim = vimUtils.buildVimPlugin {
    pname = "possession-nvim";
    version = "2023-12-10";
    src = fetchFromGitHub {
      owner = "jedrzejboczar";
      repo = "possession.nvim";
      rev = "4665ceec10991e040b7117582e62cc5edd3c964f";
      sha256 = "sha256-A32fL+dpLwNT4gA20vap5Ycm40HWMfc01a4FDQe+jQ4=";
    };
    meta.homepage = "https://github.com/cljoly/telescope-repo.nvim";
  };
}
