{ nixpkgs
, home-manager
, user
, fullname
, email
, home-modules ? [ ]
, overlays ? [ ]
}:

home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  modules = [
    { nixpkgs.overlays = overlays; }
    ../modules/home-manager/wsl/wsl.nix
    ({
      programs.git.userName = fullname;
      programs.git.userEmail = email;

      home.username = user;
      home.homeDirectory = "/home/" + user;
    })
  ] ++ home-modules;
}

