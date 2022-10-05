self: super:

let sources = import ../../nix/sources.nix; in rec {
  # My vim config
  tree-sitter-proto = self.callPackage
    (sources.nixpkgs + /pkgs/development/tools/parsing/tree-sitter/grammar.nix) { } {
    language = "proto";
    version  = "0.1.0";
    source   = sources.tree-sitter-proto;
  };

  tree-sitter-hcl = self.callPackage
    (sources.nixpkgs + /pkgs/development/tools/parsing/tree-sitter/grammar.nix) { } {
    language = "hcl";
    version  = "0.1.0";
    source   = sources.tree-sitter-hcl;
  };
}
