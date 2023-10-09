/*
* Input: Directory
* Output: a list of derivations from defined nix expression in the dir path
* Summary: From a path, get all .nix file and build their derivation using callPackage
*/

{ pkgs, lib }:

dir:
let
  files = builtins.readDir dir;
  nixFiles = builtins.attrNames files;
  nixFileFilter = lib.strings.hasSuffix ".nix";
  pkgsToBuild = builtins.filter (x: nixFileFilter x) nixFiles;
  derivations = builtins.map (p: pkgs.callPackage "${dir}/${p}" { }) pkgsToBuild;
  output = builtins.map (d: { name = d.name; value = d; }) derivations;
in
builtins.listToAttrs output
