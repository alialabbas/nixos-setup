{ pkgs, lib }:

let
  files = builtins.readDir ../pkgs;
  nixFiles = builtins.attrNames files;
  nixFileFilter = lib.strings.hasSuffix ".nix";
  pkgsToBuild = builtins.filter (x: nixFileFilter x) nixFiles;
  derivations = builtins.map (p: pkgs.callPackage ../pkgs/${p} { }) pkgsToBuild;
  output = builtins.map (d: { name = d.name; value = d; }) derivations;
in
builtins.listToAttrs output
