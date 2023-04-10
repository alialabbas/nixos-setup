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
}

