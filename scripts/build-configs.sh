#! /usr/bin/env nix-shell
#! nix-shell -i bash -p home-manager

echo "building all nixos configs"


allConfigs=$(nix flake show --json | jq -r '.nixosConfigurations|keys[]')
for config in $allConfigs
do
  echo "building $config"
  nixos-rebuild build --flake .#$config
done

# figure out a way to progmatically get all home-configuratiosn for a flake
echo "building home config"
home-manager build --flake .#home-only
