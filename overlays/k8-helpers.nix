self: super:
{
    # kube helpers
    kconfig = self.callPackage ../pkgs/kconfig.nix {};
    kforward = self.callPackage ../pkgs/kforward.nix {};
    klogs = self.callPackage ../pkgs/klogs.nix {};
    knamespace = self.callPackage ../pkgs/knamespace.nix {};
    krepl = self.callPackage ../pkgs/krepl.nix {};
    kexec = self.callPackage ../pkgs/kexec.nix {};
    # helm helpers
    hreleases = self.callPackage ../pkgs/helmreleases.nix {};
    hdelns = self.callPackage ../pkgs/hdeletenamespace.nix {};
}
