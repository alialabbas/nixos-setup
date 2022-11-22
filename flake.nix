{
  description = "NixOS development setup";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/release-22.05";

    # TODO: remove this once Nix 22.11 is released, only used with Home-Manager master
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";

      # We want home-manager to use the same set of nixpkgs as our system.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # we include home-manager unstable because it provides a nicer way
    # to configure a flake for home only
    home-manager-unstable = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # wsl modules
    nixos-wsl.url = "github:nix-community/NixOS-WSL/22.05-5c211b47";
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, ... }@inputs:
  let
    mkNix = import ./lib/mkNix.nix;

    overlays = [
      # Think of adding a centralized way to apply common overlays
      (import ./overlays/vim.nix)
      (import ./overlays/launchers.nix)
      (import ./overlays/k8-helpers.nix)
      (import ./overlays/fzf.nix)
    ];

    wsl-modules = nixos-wsl.nixosModules;

    baseWSL = mkNix { name = "wsl"; hostname = "wsl"; modules = [ wsl-modules.wsl ]; systemOverlays = [ (import ./overlays/wsl.nix) ] ++ overlays; };

    commonInputs = {
      system = "x86_64-linux";
      user = "alialabbas";
      email = "ali.n.alabbas@gmail.com";
      fullname = "Ali Alabbas";
    };
  in
  {

    baseWSL = baseWSL;

    nixosConfigurations.vm-intel = mkNix { name = "vm-intel"; hostname = "dev"; } ({
      inherit nixpkgs home-manager overlays;
    } // commonInputs);

    nixosConfigurations.wsl = baseWSL ({
      inherit nixpkgs home-manager;
      overlays = [];
    } // commonInputs);

    # TODO: use home-manager and nixkpgs once 22.11 is released
    homeConfigurations.home-only = inputs.home-manager-unstable.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux;
        modules = [
            { nixpkgs.overlays = overlays; }
            ./users/home-manager.nix
            ./home.nix
        ];
        extraSpecialArgs = {
          user = "alialabbas";
          extraPkgs = [];
          email = "ali.n.alabbas@gmail.com";
          fullname = "Ali Alabbas";
        };
    };
  };
}
