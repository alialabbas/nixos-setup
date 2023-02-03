self: super:
{
    # kube helpers
    git-url = self.callPackage ../pkgs/git-commands.nix {};
}
