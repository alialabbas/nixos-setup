{ pkgs, writeShellScriptBin }:

writeShellScriptBin "k8forward" ''
  FZF_DEFAULT_COMMAND="${pkgs.kubectl}/bin/kubectl get pods --all-namespaces" \
    fzf --info=inline --layout=reverse --header-lines=1 \
        --prompt "$(${pkgs.kubectl}/bin/kubectl config current-context | sed 's/-context$//')> " \
        --header $'╱ Enter (exec) ╱ CTRL-O (editor) ╱ CTRL-R (reload) ╱\n\n' \
        --bind 'ctrl-/:change-preview-window(80%,border-bottom|hidden|)' \
        --bind 'enter:execute:(${pkgs.kubectl}/bin/kubectl get pods -o yaml -n {1} {2} | yq .spec.containers[].ports[].containerPort | fzf --print-query | xargs -I {} ${pkgs.kubectl}/bin/kubectl port-forward {2} -n {1} {})' \
        --bind 'ctrl-r:reload:$FZF_DEFAULT_COMMAND' \
        --preview-window up:follow \
        --preview '${pkgs.kubectl}/bin/kubectl get pods -o yaml --namespace {1} {2}' "$@"
''
