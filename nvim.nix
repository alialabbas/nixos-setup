/*
* From Home-Manager config, treat neovim modules as source of truth and expose the final package.
* Wrap neovim in a simple bash script and leverage neovim remote. Inside nvim terminal, it will reuse the same nvim session
* Also creates a custom session socket when ran inside kitty terminal
*/
{ pkgs, lib, self, ... }:

let
  find = name: lib.findFirst (x: lib.strings.hasPrefix name x.name) null self.homeConfigurations.home-only.config.home.packages;
in
{
  nvim-remote = find "nvim-remote";
  nvim = (self.homeConfigurations.home-only.config.programs.neovim.finalPackage).override (previous: {
    wrapRc = true;
    neovimRcContent =
      ''
        lua << EOF
      '' +
      self.homeConfigurations.home-only.config.programs.neovim.extraLuaConfig +
      ''
        EOF
      '';
  });
}
