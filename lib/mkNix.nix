{ nixpkgs
, home-manager
, name
, system
, modules ? [ ]
, overlays ? [ ]
, home-modules ? [ ]
}:

nixpkgs.lib.nixosSystem {
  inherit system;

  modules = [
    { nixpkgs.overlays = overlays; }

    ../modules/nixos/user.nix
    ../modules/nixos/${name}/configuration.nix

    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.alialabbas = {

        imports = [
          ../modules/home-manager/${name}.nix
        ] ++ home-modules;
      };
    }
  ]
  ++ modules;
}
