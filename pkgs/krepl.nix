{ pkgs, writeShellScriptBin }:

writeShellScriptBin "krepl" ''
    export APIS=$(${pkgs.kubectl}/bin/kubectl api-resources -o name)
    FZF_DEFAULT_COMMAND='echo "$APIS"' \
         fzf --info=inline --layout=reverse --header-lines=1 \
             --no-mouse \
             --preview '${pkgs.kubectl}/bin/kubectl get {1} --all-namespaces' \
             --bind "enter:reload(${pkgs.kubectl}/bin/kubectl get {1} --all-namespaces -o custom-columns='Kind:kind,Name:metadata.name,Namespace:metadata.namespace' --sort-by=.metadata.namespace)" \
             --bind "enter:+clear-query" \
             --bind "enter:+change-preview(${pkgs.kubectl}/bin/kubectl get {1} {2} -n {3} -o yaml | bat -l yaml --color=always)" \
             --bind 'ctrl-r:reload:(echo "$APIS")' \
             --bind 'ctrl-r:+change-preview(${pkgs.kubectl}/bin/kubectl get {1} --all-namespaces)' \
             --bind 'ctrl-r:+clear-query' \
             --header 'Press CTRL-R to reload' \
             --bind 'ctrl-]:execute(${pkgs.kubectl}/bin/kubectl edit {1} {2} -n {3})';
''
