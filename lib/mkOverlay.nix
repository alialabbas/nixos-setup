/*
 * Glue code for creating an overlay lambda for a overrides from a specific source
 * Useful when you want to include an upgrade version from unstable registry without manually writing the overlay yourself
 * It is also able to handle nested packages like nodePackages or vimPlugins
 */

/*
 * registry: overrides: self: super:
 * builtins.listToAttrs
 * (builtins.map (x: { name = x; value = registry.${x}; }) overrides)
 */

# group method
# nix-repl> method = x: let splitString = lib.strings.splitString "." x; group = if lib.lists.length splitString == 1 then "all" else builtins.head splitString
# nix-repl> x = lib.strings.splitString "." "firefox"
# nix-repl> x = lib.lists.groupBy (method) ["vimPlugins.neotest" "fusuma" "firefox" "vimPlugins.neorg"]
# This can be done with group and just handle each independetally
# could also stick with a basic method that handle the first branch or something recursive
# The core issue stems from not having the whole overlay for vimPlugins so we need to overlay that
# and not just override the whole thing
prefix: pkgs: list: final: prev:

if builtins.typeOf prefix != "string" then throw "prefix is expected to be a string"
else
  let
    result =
      builtins.listToAttrs
        (builtins.map
          (elem:
            if prefix == ""
            then { name = elem; value = pkgs.${elem}; }
            else { name = elem; value = pkgs.${prefix}.${elem}; })
          list);
  in
  if prefix == "" then
    result
  else
    {
      ${prefix} = prev.${prefix}.extend (final': prev': result);
    }
