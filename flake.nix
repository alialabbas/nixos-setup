{
  description = "NixOS development setup";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/release-22.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # wsl modules
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, ... }:
    let
      mkNix = import ./lib/mkNix.nix;
      mkHome = import ./lib/mkHome.nix;
      system = "x86_64-linux";
    in
    {
      lib = {
        mkNix = mkNix;
        mkHome = mkHome;
      };

      nixosConfigurations.hyperv = mkNix {
        inherit nixpkgs home-manager system;
        name = "hyperv";
        hostname = "dev";
        user = "alialabbas";
        fullname = "Ali Alabbas";
        email = "ali.n.alabbas@gmail.com";
      };

      nixosConfigurations.wsl = mkNix {
        inherit nixpkgs home-manager system;
        name = "wsl";
        hostname = "wsl";
        modules = [ nixos-wsl.nixosModules.wsl ];
        user = "alialabbas";
        fullname = "Ali Alabbas";
        email = "ali.n.alabbas@gmail.com";
        overlays = [ (import ./overlays/wsl.nix) ];
      };

      homeConfigurations.home-only = mkHome {
        inherit nixpkgs home-manager;
        user = "alialabbas";
        fullname = "Ali Alabbas";
        email = "ali.n.alabbas@gmail.com";
      };
    };
}

