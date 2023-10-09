{ lib, ... }:

{
  programs.bash = {
    enable = lib.mkDefault true;
    shellOptions = [ ];
    historyControl = [ "ignoredups" "ignorespace" ];
    initExtra = ''
      # Use the windows host browser if we are running in a wsl env
      if [ ! -z "$${WSLENV}" ]; then
          export BROWSER=wslview
      fi
    '';
    # For non-nixos system, load nix when a shell starts
    profileExtra = ''
      if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then . ~/.nix-profile/etc/profile.d/nix.sh; fi # for non nixos env we need to load nix
    '';
  };
}
