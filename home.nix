{ config, pkgs, user ? "alialabbas",... }:

{
  home.username = user;
  home.homeDirectory = "/home/" + user;
  home.stateVersion = "22.05";
  # Let home-manager install and manage itself
  programs.home-manager.enable = true;
}
