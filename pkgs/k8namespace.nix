{ pkgs, writeShellScriptBin }:

writeShellScriptBin "k8namespace" ''
  FZF_DEFAULT_COMMAND="kubectl get namespaces" \
      fzf --info=inline --layout=reverse --header-lines=1 \
          --header $'/ Enter to select a namespace to work with\n\n' \
          --bind 'ctrl-/:change-preview-window(80%,border-bottom|hidden|)' \
          --bind 'enter:execute(kubectl config set-context --current --namespace={1})' \
          --bind 'enter:+abort'
''

