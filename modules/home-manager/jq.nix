{ config, pkgs, ... }:

{
  # Symlink utils.jq to ~/.jq for interactive use
  home.file.".jq".source = ../../jq-scripts/utils.jq;
  
  # Add the shell helper to bash
  programs.bash.initExtra = ''
    # jenv helper: loads JSON as environment variables
    jenv() {
      if [ -z "$1" ]; then
        echo "Usage: jenv <file.json>"
        return 1
      fi
      # Use the packaged jq and the script from the nix store or relative path
      # For purity in the shell function, we can reference the jq-scripts from the store 
      # if we want, but using a function that evals is the goal here.
      eval "$(${pkgs.jq}/bin/jq -s -r -L ${config.home.homeDirectory}/.jq -f ${../../jq-scripts/j2env.jq} "$@")"
    }
  '';
}
