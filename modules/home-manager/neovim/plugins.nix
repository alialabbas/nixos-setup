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
    meta.homepage = "https://github.com/someone-stole-my-name/yaml-companion.nvim";
  };
}
