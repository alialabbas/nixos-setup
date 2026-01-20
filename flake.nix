{
  description = "NixOS development setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
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

    flake-compat = {
      url = "github:inclyc/flake-compat";
      flake = false;
    };

    nur.url = "github:nix-community/NUR";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , nixos-wsl
    , nixos-hardware
    , ...
    }@inputs:

    let
      system = "x86_64-linux";

      overlays =
        [
          inputs.nur.overlays.default
          inputs.neovim-nightly-overlay.overlays.default
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
        neovim = inputs.nixpkgs.legacyPackages.${system}.neovim;
        # neovim = inputs.neovim-nightly-overlay.packages.${system}.default;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            inputs.neovim-nightly-overlay.overlays.default
          ];
        };
        lib = nixpkgs.lib;
      };

      homeConfigurations.home-only = import ./lib/mkHome.nix {
        inherit nixpkgs home-manager overlays;
      };
    };
}
