{
  description = "NixOS development setup";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/release-22.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

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

  outputs = { self, nixpkgs, home-manager, nixos-wsl, ... }@inputs:
    let
      mkNix = import ./lib/mkNix.nix;
      mkHome = import ./lib/mkHome.nix;
      system = "x86_64-linux";
      # TODO: if this works, I should make a simpler method to pull from an array of inputs
      overlays = [
        (
          self: super: {
            lua-language-server = inputs.unstable.legacyPackages.${system}.lua-language-server;
            nvim-lspconfig = inputs.unstable.legacyPackages.${system}.nvim-lspconfig;
          }
        )
      ];
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

