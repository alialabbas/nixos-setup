/*
 * Glue code for creating an overlay lambda for a overrides from a specific source
 * Useful when you want to include an upgrade version from unstable registry without manually writing the overlay yourself
 */

registry: overrides: self: super:

builtins.listToAttrs
  (builtins.map (x: { name = x; value = registry.${x}; }) overrides)
