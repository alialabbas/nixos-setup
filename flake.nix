{
  description = "NixOS development setup";

  inputs = {
    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    nixpkgs.url = "github:nixos/nixpkgs/release-22.05";

    nixos-configuration = {
      url = "path:/etc/nixos";
      flake = false;
    };

    # Locks nixpkgs to an older version with an older Kernel that boots
    # on VMware Fusion Tech Preview. This can be swapped to nixpkgs when
    # the TP fixes the bug.
    nixpkgs-old-kernel.url = "github:nixos/nixpkgs/bacbfd713b4781a4a82c1f390f8fe21ae3b8b95b";

    # We use the unstable nixpkgs repo for some packages.
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

    # Other packages
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # wsl modules
    nixos-wsl.url = "github:nix-community/NixOS-WSL/22.05-5c211b47";
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, ... }@inputs:
  let
    mkVM = import ./lib/mkvm.nix;

    # Overlays is the list of overlays we want to apply from flake inputs.
    overlays = [
      inputs.neovim-nightly-overlay.overlay

      (final: prev: {
        # To get Kitty 0.24.x. Delete this once it hits release.
        kitty = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.kitty;
      })
      # Think of adding a centralized way to apply common overlays
      (import ./overlays/vim.nix)
      (import ./overlays/k8-helpers.nix)
      (import ./overlays/launchers.nix)
      (import ./overlays/fzf.nix)
    ];

    wsl-modules = nixos-wsl.nixosModules;
  in
  {
    nixosConfigurations.vm-intel = mkVM "vm-intel" rec {
      inherit nixpkgs home-manager overlays;
      system = "x86_64-linux";
      user   = "alialabbas";
    };

    nixosConfigurations.wsl = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        { nixpkgs.overlays = overlays ++ [ (import ./overlays/wsl.nix) ]; }
        wsl-modules.wsl
        ./users/alialabbas/nixos.nix
        ./users/alialabbas/wsl.nix
        ./machines/vm-shared.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.alialabbas = import ./users/alialabbas/home-manager.nix;
        }
      ];
    };

    homeConfigurations.home-only = inputs.home-manager-unstable.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux;
        modules = [
            { nixpkgs.overlays = overlays; }
            ./users/alialabbas/home-manager.nix
            ./home.nix
        ];
    };
  };
}
