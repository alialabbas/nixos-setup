{ pkgs, lib, ... }:

let

  scripts = pkgs.stdenv.mkDerivation {
    name = "jq-scripts";
    src = ./../jq-scripts;
    installPhase = "mkdir -p $out/share/jq-scripts && cp *.jq $out/share/jq-scripts/";
  };

  # Get all .jq files except utils.jq
  # builtins.readDir on a path literal from the flake source is allowed.
  files = builtins.readDir ./../jq-scripts/.;
  jqFiles = lib.filterAttrs (n: v: v == "regular" && lib.hasSuffix ".jq" n && n != "utils.jq") files;
  toolNames = map (lib.removeSuffix ".jq") (builtins.attrNames jqFiles);

  # Create a derivation for a single tool
  mkTool = name:
    let
      jq = "${pkgs.jq}/bin/jq";
      libDir = "${scripts}/share/jq-scripts";

      # Flags: jsort uses compact output, others use raw
      flags = if name == "jsort" then "-s -c" else "-s -r";

      # Pipe: jtable uses column for formatting
      pipe =
        if name == "jtable"
        then " | ${pkgs.util-linux}/bin/column -t -s $'	' -o ' | '"
        else "";

      script = ''
        ${jq} ${flags} -L ${libDir} -f ${libDir}/${name}.jq "$@" ${pipe}
      '';
    in
    pkgs.writeShellScriptBin name script;

in
pkgs.symlinkJoin {
  name = "alialabbas-jq-tools";
  paths = [ scripts ] ++ (map mkTool toolNames);
}
