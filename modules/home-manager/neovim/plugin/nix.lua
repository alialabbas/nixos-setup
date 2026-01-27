local nix = require("nix")

vim.api.nvim_create_user_command("NixShell", function(opts)
    nix.shell(opts.args)
end, {
    nargs = "+",
    complete = function(ArgLead, CmdLine, CursorPos)
        -- Optional: Add completion for nixpkgs if possible, 
        -- but for now simple package names are fine.
        return {}
    end,
})
