# Overlay Apps that depends on IPTables like docker and k3s
self: super: {
  docker = super.docker.override { iptables = super.pkgs.iptables-legacy; };
  k3s = super.k3s.override { iptables = super.pkgs.iptables-legacy; };
  neovim = super.neovim.overrideAttrs (old: rec {
    version = "0.9.0";
    src = super.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "v${version}";
      hash = "sha256-4uCPWnjSMU7ac6Q3LT+Em8lVk1MuSegxHMLGQRtFqAs=";
    };
  });
}
