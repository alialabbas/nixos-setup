{
  description = "NixOS development setup";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
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

    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-compat = {
      url = "github:inclyc/flake-compat";
      flake = false;
    };

    nickel-unstable = {
      url = "github:tweag/nickel";
    };

    nur.url = "github:nix-community/NUR";
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , nixos-wsl
    , nixos-hardware
    , nickel-unstable
    , ...
    }@inputs:

    let
      system = "x86_64-linux";

      overlays =
        [
          inputs.nur.overlay

          (import ./lib/mkOverlay.nix "vimPlugins" inputs.nixos-unstable.legacyPackages.${system} [ "neotest" ])

          (self: super: {
            neovim = inputs.nixos-unstable.legacyPackages.${system}.neovim;
            neovim-unwrapped = inputs.nixos-unstable.legacyPackages.${system}.neovim-unwrapped;
            nickel = inputs.nickel-unstable.packages.${system}.nickel-lang-cli;
            nls = inputs.nickel-unstable.packages.${system}.nickel-lang-lsp;
          })
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
