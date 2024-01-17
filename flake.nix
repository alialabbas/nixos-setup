{
  description = "NixOS development setup";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/release-23.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
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

    # This should be removed once neovim has an official release for 0.10
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };

    # This should be removed in the next nixos release cycle
    # Fusuma + vimPlugins.neotest are broken in the current cycle
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , nixos-wsl
    , nixos-hardware
    , neovim-nightly-overlay
    , ...
    }@inputs:

    let
      system = "x86_64-linux";

      overlays =
        [
          (import ./lib/mkOverlay.nix "" inputs.unstable.legacyPackages.${system} [ "fusuma" ])
          (import ./lib/mkOverlay.nix "vimPlugins" inputs.unstable.legacyPackages.${system} [ "neotest" ])
          neovim-nightly-overlay.overlay
        ];

      # Any nixosConfiguration get added here
      configurations = [
        {
          name = "wsl";
          overlays = [ (import ./overlays/wsl.nix) ] ++ overlays;
          modules = [ nixos-wsl.nixosModules.wsl ];
        }
        {
          name = "hyperv";
          overlays = overlays;
          modules = [ ];
        }
        {
          name = "framework";
          overlays = overlays;
          modules = [ nixos-hardware.nixosModules.framework-13th-gen-intel ];
        }
      ];
      machines = builtins.map
        (machine: {
          name = machine.name;
          value = import ./lib/mkNix.nix {
            inherit nixpkgs home-manager system;
            modules = machine.modules;
            name = machine.name;
            overlays = machine.overlays;
          };
        })
        configurations;
    in
    {
      nixosConfigurations = builtins.listToAttrs machines;
      devShells = {
        x86-64_linux = {
          default = import ./shell.nix {
            pkgs = nixpkgs.legacyPackages.${system};
          };
          home = import ./shell-home.nix {
            pkgs = nixpkgs.legacyPackages.${system};
            self = self;
          };
        };
      };

      packages.${system} = import ./nvim.nix {
        inherit self;
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;
      };

      homeConfigurations.home-only = import ./lib/mkHome.nix {
        inherit nixpkgs home-manager overlays;
      };
    };
}
