{ curl
, writeShellScriptBin
, jq
}:

writeShellScriptBin "nugetVersions" ''
  ${curl}/bin/curl -s https://api.nuget.org/v3-flatcontainer/$1/index.json | ${jq}/bin/jq -r .versions[]
''
