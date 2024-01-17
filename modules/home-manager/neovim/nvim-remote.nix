/*
 * Simple wrapper to handle nvim-remote functionalities
 * Supports nested terminal inside neovim based on toggleterm
 * Also can be used to run a server hooked into a kitty session
 */
{ writeShellScriptBin, nvim, ... }:

let
  myNvim = nvim.override (previous: {
    wrapRc = true;
    neovimRcContent =
      ''
        lua << EOF
      '' +
      builtins.readFile ./init.lua +
      ''
        EOF
      '';
  });
in
writeShellScriptBin "nvim-remote" ''
  if [ ! -z "$NVIM" ] || [ -S "/run/user/$UID/kitty-nvim.$KITTY_PID" ]; then
      if [ -v $NVIM ]; then NVIM=/run/user/$UID/kitty-nvim.$KITTY_PID; fi
      ${myNvim}/bin/nvim --server $NVIM --remote-send\
      "<cmd>lua require('toggleterm').close_all()<CR>:e $@<CR>"
  elif [ ! -z $"KITTY_PID" ]; then
      ${myNvim}/bin/nvim --listen "/run/user/$UID/kitty-nvim.$KITTY_PID" "$@"
  else
      ${myNvim}/bin/nvim "$@"
  fi
''
