{
  description = "NixOS development setup";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/release-23.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # wsl modules
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, ... }@inputs:
    let
      mkNix = import ./lib/mkNix.nix;
      mkHome = import ./lib/mkHome.nix;
      system = "x86_64-linux";
      myOverrides = [ "nil" "nvim-lspconfig" "lua-language-server" ];
      # TODO: move this stuff to keep the flake clean from various code
      myFunctor = registry: overrides: self: super:
        builtins.listToAttrs (builtins.map (x: { name = x; value = registry.${x}; }) overrides);
      overlays = [ (myFunctor inputs.unstable.legacyPackages.${system} myOverrides) ];
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
        overlays = [ (import ./overlays/wsl.nix) ] ++ overlays;
      };

      homeConfigurations.home-only = mkHome {
        inherit nixpkgs home-manager;
        user = "alialabbas";
        fullname = "Ali Alabbas";
        email = "ali.n.alabbas@gmail.com";
      };
    };
}

