/*
* From Home-Manager config, treat neovim config as source and from there expose it in a shell
* This is useful when you share the same NixSetup as other developers in a workplace and don't want to add your own setup as a dependency
*/
{ pkgs, self, ... }:

let
  myConfig = pkgs.writeText "init.lua" self.homeConfigurations.home-only.config.programs.neovim.extraLuaConfig;
  myNvim = pkgs.neovim.override {
    configure = {
      packages.myVimPackage = {
        start = self.homeConfigurations.home-only.config.programs.neovim.plugins; # This is neat, clever, smart. This is one way to solve it
        opt = [ ];
      };
    };
  };
in
pkgs.mkShell {
  name = "nvim-shell";
  buildInputs = with pkgs;[
    myNvim
    neovide
  ] ++ self.homeConfigurations.home-only.config.programs.neovim.extraPackages;
  shellHook = ''
    alias nvim="nvim -u ${myConfig}"
  '';
}
