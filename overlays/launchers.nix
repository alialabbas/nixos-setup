# overlay for creating custom desktop launchers, kitty here is only useful for WSL setup
self: super:
{
  # href https://discourse.nixos.org/t/how-do-i-create-a-custom-application-launcher-in-gnome-shell/12179/3
  kitty-launcher = super.stdenv.mkDerivation rec {
    name = "kitty-launcher";
    dontbuild = true;
    unpackPhase = "true";
    desktopItem = super.makeDesktopItem {
      name = "kitty-launcher";
      exec = "${self.pkgs.kitty}/bin/kitty";
      desktopName = "kitty-launcher";
      terminal = false;
    };
    installPhase = ''
      mkdir -p $out/share
      cp -r ${desktopItem}/share/applications $out/share
    '';
  };
}

