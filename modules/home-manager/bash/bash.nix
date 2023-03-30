{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.bash;
in
{
  options.modules.bash = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };

    extraBashrc = mkOption {
      default = "";
      type = types.lines;
      example = ''
        export ENV=TEST
      '';
      description = "Additional bashrc lines to add to the common bashrc";
    };
  };
  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      shellOptions = [ ];
      historyControl = [ "ignoredups" "ignorespace" ];
      initExtra = builtins.readFile ./bashrc + cfg.extraBashrc;
      profileExtra = ''
        if [ -e /home/alialabbas/.nix-profile/etc/profile.d/nix.sh ]; then . /home/alialabbas/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
      '';
    };
  };
}
