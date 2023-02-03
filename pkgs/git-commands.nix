# Simple utility command for switching k8 config in an interactive way
{ pkgs, writeShellScriptBin }:
# url = "bash -c blob=-/blob/master; url=$(git config --get  remote.origin.url); if [[ $url == *.git ]]; then echo \${url:: -3}/$blob/$1 ; fi";
writeShellScriptBin "git-url" ''
    echo test
''
