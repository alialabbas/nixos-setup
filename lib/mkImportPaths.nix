{ lib, ... }:

/*
* Input: directory path
* Output: Imports paths for all modules that have suffix/suffix.nix in the searched path
*/
dir:
let
  modules = lib.filterAttrs (k: v: v == "directory") (builtins.readDir dir);
in
builtins.map
  (x: dir + x + x + ".nix")
  (builtins.map
    (x: "/" + x + "/")
    (builtins.attrNames modules))
