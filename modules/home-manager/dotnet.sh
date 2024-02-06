# bash parameter completion for the dotnet CLI
# href: https://learn.microsoft.com/en-us/dotnet/core/tools/enable-tab-autocomplete
# Slightly modified to provide custom paths for specific options only
# and not through -f option

function _dotnet_bash_complete()
{
  local cur="${COMP_WORDS[COMP_CWORD]}" IFS=$'\n'
  local candidates

  read -d '' -ra candidates < <(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2>/dev/null)

  prev="${COMP_WORDS[COMP_CWORD-1]}"
  case "${prev}" in
      build|--project|test|list)
        local paths=$(find . -name "*.csproj" 2>/dev/null)
        local all=("${candidates[@]}" "${paths[@]}")
        read -d '' -ra COMPREPLY < <(compgen -W "${all[*]:-}" -- "$cur")
              ;;
      *)

        read -d '' -ra COMPREPLY < <(compgen -W "${candidates[*]:-}" -- "$cur")
      ;;
  esac
}

complete -F _dotnet_bash_complete dotnet
