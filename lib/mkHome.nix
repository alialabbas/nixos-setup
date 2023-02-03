{ nixpkgs, home-manager, overlays }: { user, email, fullname,  extraPkgs ? [], extraBashrc ? ''''}:

home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  modules = [
    { nixpkgs.overlays = overlays; }
    ../users/home-manager.nix
    ../home.nix
  ];
  extraSpecialArgs = {
    user = user;
    extraPkgs = extraPkgs;
    email = email;
    fullname = fullname;
    extraBashrc = extraBashrc;
    };
}

