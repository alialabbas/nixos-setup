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
        wslConf = {
            network = {
                hostname = "wsl";
            };
        };
    };

}
