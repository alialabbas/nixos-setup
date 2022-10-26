{ pkgs, writeShellScriptBin }:

# kexec command-to-run
# TODO: figure out why this doesn't work when I pass -c $container
writeShellScriptBin "kexec" ''
  namespace=`kubectl get ns | sed 1d | awk '{print $1}' | fzf`
  pod=`kubectl get pods -n $namespace | sed 1d | awk '{print $1}' | fzf`
  # $container=`kubectl get pods -n $namespace $pod -o yaml | yq .spec.containers[].name`
  if [ -z $1 ]
  then
    kubectl -n $namespace exec -it $pod -- sh
  else
    kubectl -n $namespace exec -it $pod -- $1
  fi
''
