{ config, pkgs, ... }:

{
  home.username = "alialabbas";
  home.homeDirectory = "/home/alialabbas";
  home.stateVersion = "22.05";
  # Let home-manager install and manage itself
  programs.home-manager.enable = true;
}
