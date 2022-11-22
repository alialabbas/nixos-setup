# A function that I use and expose in my flake to allow me to configure a base nixosSystem that has pre-baked modules
# that I want to be used all the time and allow me to extend this base further
{ name, hostname, modules ? [], systemOverlays ? [] }: { nixpkgs, home-manager, system, user, overlays, email, fullname, extraMods ? [], extraPkgs ? [] }:

nixpkgs.lib.nixosSystem {
  inherit system;

  modules = [
    { nixpkgs.overlays = overlays ++ systemOverlays; }

    # this is a common structure that I might just change and make this a dummy method
    # to just set up the modules
    ../hardware/${name}.nix
    ../machines/${name}.nix
    ../users/nixos.nix
    home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = import ../users/home-manager.nix;
      home-manager.extraSpecialArgs = {
        user = user;
        email = email;
        extraPkgs = extraPkgs;
        fullname = fullname;
      };
    }

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        user = user;
        hostname = hostname;
      };
    }
  ]
  ++ modules
  ++ extraMods;
}
