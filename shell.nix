{ pkgs, ... }:

# TODO: actually, when you think about it. If I just pass the ref here I should be able to reference the output I think and get the name of each attributes on the fly for generating the configs without querying nix itself.
# The only downside to this approach if the flake changes we would need to reload it somehow to find the outputs
let
  buildScript = pkgs.writeShellScriptBin "build-all" ''
    echo "building all nixos configs"
    allConfigs=$(nix flake show --json | ${pkgs.jq}/bin/jq -r '.nixosConfigurations|keys[]')
    for config in $allConfigs
    do
      echo "building $config"
      nixos-rebuild build --flake .#$config
    done

    # TODO: with flake schema we should be able to query all home configs
    echo "building home config"
    ${pkgs.home-manager}/bin/home-manager build --flake .#home-only
  '';
in
pkgs.mkShell {
  name = "nixos-shell";
  buildInputs = [
    buildScript
  ];

  shellHook = ''
    echo "Welcome to the dev shell"
    echo "You can run the following inside this shell"
    echo "${buildScript.name} => Build all configurations nixos & home-manager"
  '';
}
