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

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, nixos-hardware, ... }@inputs:
    let
      system = "x86_64-linux";
      myOverrides = [ /* "neovim"  */ ];
      overlays = [ (import ./lib/mkOverlay.nix inputs.unstable.legacyPackages.${system} myOverrides) ];

      # Any nixosConfiguration get added here
      configurations = [
        { name = "wsl"; overlays = [ (import ./overlays/wsl.nix) ] ++ overlays; modules = [ nixos-wsl.nixosModules.wsl ]; }
        { name = "hyperv"; overlays = [ ]; modules = [ ]; }
        { name = "framework"; overlays = overlays; modules = [ nixos-hardware.nixosModules.framework-13th-gen-intel ]; }
      ];
      machines = builtins.map
        (machine: {
          name = machine.name;
          value = import ./lib/mkNix.nix { inherit nixpkgs home-manager system; modules = machine.modules; name = machine.name; overlays = machine.overlays; };
        })
        configurations;
    in
    {
      nixosConfigurations = builtins.listToAttrs machines;

      homeConfigurations.home-only = import ./lib/mkHome.nix {
        inherit nixpkgs home-manager;
      };
    };
}
