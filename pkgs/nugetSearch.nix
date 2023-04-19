{ curl
, jq
, writeShellScriptBin
}:

writeShellScriptBin "nugetSearch" ''
  data=$(${curl}/bin/curl -s https://api-v2v3search-0.nuget.org/autocomplete?q=$1&take=100&includeDelisted=false)
  echo $data | ${jq}/bin/jq -r '.data | join("\n")'
''
