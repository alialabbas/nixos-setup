# Simple utility command for switching k8 config in an interactive way
{ pkgs, writeShellScriptBin }:

writeShellScriptBin "k8config" ''
  FZF_DEFAULT_COMMAND="${pkgs.kubectl}/bin/kubectl config get-contexts" \
        fzf --info=inline --layout=reverse --header-lines=1 \
            --prompt "$(${pkgs.kubectl}/bin/kubectl config current-context | sed 's/-context$//')> " \
            --header $'╱ Enter (exec) ╱ CTRL-O (open log in editor) ╱ CTRL-R (reload) ╱\n\n' \
            --bind 'ctrl-/:change-preview-window(80%,border-bottom|hidden|)' \
            --bind 'enter:execute:(${pkgs.kubectl}/bin/kubectl config use-context {1})' \
            --bind 'enter:+abort' \
            --bind 'ctrl-r:reload:$FZF_DEFAULT_COMMAND'
''
