{ pkgs, writeShellScriptBin }:

writeShellScriptBin "hdelns" ''
if [ -z "$1" ]
  then
    echo "Pass namespace"
  else
	  helm ls -n $1 -o json  | jq .[].name | xargs -I {} helm delete -n $1 {}
fi
''
