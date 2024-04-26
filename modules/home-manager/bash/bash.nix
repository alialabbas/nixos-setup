{ lib, pkgs, ... }:

{
  programs.bash = {
    enable = lib.mkDefault true;
    shellOptions = [ ];
    historyControl = [ "ignoredups" "ignorespace" ];

    # For non-nixos system, load nix when a shell starts
    profileExtra = ''
      if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then . ~/.nix-profile/etc/profile.d/nix.sh; fi # for non nixos env we need to load nix
    '';

    shellAliases = { jsonpath = "${pkgs.jq}/bin/jq 'select(objects)|=[.] | map( paths(scalars) ) | map( map(select(numbers)=\"[]\") | join(\".\")) | unique'"; };
  };
}
