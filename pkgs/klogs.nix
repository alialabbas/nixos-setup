{ pkgs, writeShellScriptBin }:

writeShellScriptBin "klogs" ''
    FZF_DEFAULT_COMMAND="${pkgs.kubectl}/bin/kubectl get pods --all-namespaces" \
		fzf --info=inline --layout=reverse --header-lines=1 \
            --bind 'enter:execute:(${pkgs.kubectl}/bin/kubectl get pods -o yaml -n {1} {2} | yq .spec.containers[].name | fzf --print-query --preview "${pkgs.kubectl}/bin/kubectl -n {1} logs {2} -c \{1}")' \
            --bind "enter:+clear-query" \
            --bind "enter:+change-preview(${pkgs.kubectl}/bin/kubectl get {1} {2} -n {3} -o yaml | bat -l yaml --color=always)" \
            --bind 'ctrl-r:change-preview(${pkgs.kubectl}/bin/kubectl logs -n {1} {2}) "$@" ' \
            --preview-window up:follow:wrap \
            --preview '${pkgs.kubectl}/bin/kubectl logs -n {1} {2}' "$@"
''

