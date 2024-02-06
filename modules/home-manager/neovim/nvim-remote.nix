/*
 * Simple wrapper to handle nvim-remote functionalities
 * Supports nested terminal inside neovim based on toggleterm
 * Also can be used to run a server hooked into a kitty session
 */
{ writeShellScriptBin, nvim, config, ... }:

let
  myNvim = nvim.override (previous: {
    wrapRc = true;
    neovimRcContent =
      ''
        lua << EOF
      '' +
      config
      +
      # builtins.readFile ./init.lua + # fixme: this should take the config from home-manager config
      ''
        EOF
      '';
  });
in
writeShellScriptBin "nvim-remote" ''
  if [ ! -z "$NVIM" ] || [ -S "/run/user/$UID/kitty-nvim.$KITTY_PID" ]; then
      if [ -v $NVIM ]; then NVIM=/run/user/$UID/kitty-nvim.$KITTY_PID; fi
        # this is weird but the actual output I care about here is the path goes to stderr
        curr_dir=$(nvim --server $NVIM --remote-expr "v:lua.vim.loop.cwd()" 2>&1 1>/dev/null)
        nvimcmd=":e"
        if [ "$#" -ne 1 ]; then
          nvimcmd=":vsplit"
          fi

        for file in "$@"
        do
          fullpath=$(realpath $file)
          if [[ $fullpath != "$curr_dir"* ]]; then
            nvimcmd=":tabe"
          fi
          ${myNvim}/bin/nvim --server $NVIM --remote-send\
            "<cmd>lua require('toggleterm').close_all()<CR><esc>$nvimcmd $fullpath<CR>"
        done
  elif [ ! -z $"KITTY_PID" ]; then
      ${myNvim}/bin/nvim --listen "/run/user/$UID/kitty-nvim.$KITTY_PID" "$@"
  else
      ${myNvim}/bin/nvim "$@"
  fi
''
