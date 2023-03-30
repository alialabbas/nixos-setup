{
  description = "NixOS development setup";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/release-22.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";

      # We want home-manager to use the same set of nixpkgs as our system.
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

    overlays = [
      # Think of adding a centralized way to apply common overlays
      #(import ./overlays/vim.nix)
      (import ./overlays/launchers.nix)
      (import ./overlays/k8-helpers.nix)
      (import ./overlays/fzf.nix)
      (import ./overlays/git-helpers.nix)
    ];

    wsl-modules = nixos-wsl.nixosModules;

    baseWSL = mkNix { name = "wsl"; hostname = "wsl"; modules = [ wsl-modules.wsl ]; systemOverlays = [ (import ./overlays/wsl.nix) ] ++ overlays; };

    baseHome = mkHome { inherit nixpkgs home-manager overlays; };
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    commonInputs = {
      system = "x86_64-linux";
      user = "alialabbas";
      email = "ali.n.alabbas@gmail.com";
      fullname = "Ali Alabbas";
      extraPkgs = [
        pkgs.nodePackages.vim-language-server
        pkgs.nodePackages.yaml-language-server
        pkgs.python39Packages.python-lsp-server
        pkgs.python39
        ];
    };
  in
  {

    baseWSL = baseWSL;
    baseHome = baseHome;

    # TODO: similar to how I am building packages based on a patch, it would be great to utilize the tree structure to create these modules
    nixosModules.home.common = import ./users/home-manager.nix;
    nixosModules.home.vim = import ./modules/home-manager/vim/vim.nix;
    nixosModules.home.git = import ./modules/home-manager/git/git.nix;

    nixosConfigurations.vm-intel = mkNix { name = "vm-intel"; hostname = "dev"; } ({
      inherit nixpkgs home-manager overlays;
    } // commonInputs);

    nixosConfigurations.wsl = baseWSL ({
      inherit nixpkgs home-manager;
      overlays = [];
    } // commonInputs);

    homeConfigurations.home-only = baseHome ({} // (builtins.removeAttrs commonInputs ["system"]));

  };
}
