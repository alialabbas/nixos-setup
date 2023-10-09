{ nixpkgs
, home-manager
, home-modules ? [ ]
, overlays ? [ ]
}:

home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  modules = [
    { nixpkgs.overlays = overlays; }
    ../modules/home-manager/wsl.nix
  ] ++ home-modules;
}

