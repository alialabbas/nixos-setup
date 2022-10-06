# Overlay Apps that depends on IPTables like docker and k3s
self: super: {
  docker = super.docker.override { iptables = super.pkgs.iptables-legacy; };
  k3s = super.k3s.override { iptables = super.pkgs.iptables-legacy; };
}
