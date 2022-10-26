{ pkgs, writeShellScriptBin }:

writeShellScriptBin "hreleases" ''
      FZF_DEFAULT_COMMAND="${pkgs.kubernetes-helm}/bin/helm list --all-namespaces" \
        fzf --info=inline --layout=reverse --header-lines=1 \
            --prompt "$(kubectl config current-context | sed 's/-context$//')> " \
            --header $'╱ CTRL-M (manifest) ╱ CTRL-V (values) / CTRL-A (all) / CTRL-H (hooks) ╱ CTRL-R (reload) ╱\n\n' \
            --bind 'ctrl-/:change-preview-window(80%,border-bottom|hidden|)' \
            --bind 'ctrl-a:change-preview:${pkgs.kubernetes-helm}/bin/helm get all {1} -n {2}' \
            --bind 'ctrl-m:change-preview:${pkgs.kubernetes-helm}/bin/helm get manifest {1} -n {2}' \
            --bind 'ctrl-n:change-preview:${pkgs.kubernetes-helm}/bin/helm get notes {1} -n {2}' \
            --bind 'ctrl-v:change-preview:${pkgs.kubernetes-helm}/bin/helm get values {1} -n {2}' \
            --bind 'ctrl-h:change-preview:${pkgs.kubernetes-helm}/bin/helm get hooks {1} -n {2}' \
            --bind 'ctrl-r:reload:$FZF_DEFAULT_COMMAND' \
            --preview-window up:follow \
            --preview '${pkgs.kubernetes-helm}/bin/helm get values {1} -n {2}' "$@"
 ''
