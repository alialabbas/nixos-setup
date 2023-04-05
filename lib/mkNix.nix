{ nixpkgs
, home-manager
, name
, hostname
, system
, user
, fullname
, email
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

    ({ pkgs, lib, ... }: {
      modules.systemConfig =
        {
          user = user;
          hostname = hostname;
        };
    })

    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = {

        imports = [
          ../modules/home-manager/${name}/${name}.nix
        ] ++ home-modules;

        programs.git.userName = fullname;
        programs.git.userEmail = email;

        home.username = user;
        home.homeDirectory = "/home/" + user;
      };
    }
  ]
  ++ modules;
}
