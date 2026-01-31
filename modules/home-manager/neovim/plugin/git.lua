local function define_git_proxy()
    vim.api.nvim_create_user_command("Git", function(opts)
        require("git").proxy(opts)
    end, {
        nargs = "*",
        range = true,
        bang = true,
        complete = function(ArgLead, CmdLine, CursorPos)
            return require("git").complete(ArgLead, CmdLine, CursorPos)
        end,
        desc = "Async Git proxy for ls-files, delegates others to Fugitive"
    })
end

local is_headless = #vim.api.nvim_list_uis() == 0

if is_headless then
    define_git_proxy()
else
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = define_git_proxy,
        once = true,
    })
end

vim.keymap.set("n", "]g", ":Gitsigns next_hunk<CR>", { silent = true, desc = "Next edited hunk in a file" })
vim.keymap.set("n", "[g", ":Gitsigns prev_hunk<CR>", { silent = true, desc = "Prev edited hunk in a file" })
