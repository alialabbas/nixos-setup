{ lib, pkgs, config, modulesPath, ... }:

with lib;
{
    imports = [
        "${modulesPath}/profiles/minimal.nix"
    ];

    wsl = {
        enable = true;
        automountPath = "/mnt";
        defaultUser = "alialabbas";
        startMenuLaunchers = true;
    };

    nix.package = pkgs.nixFlakes;
    nix.extraOptions = ''
        experimental-features = nix-command flakes
    '';

    system.stateVersion = "22.05";

}
