_G.BookmarkAction = function(minwid, clicks, button, mods)
    local mPos = vim.fn.getmousepos()
    vim.api.nvim_command(string.format("%d", mPos.line))

    if button == "l" then
        vim.api.nvim_command('BookmarkToggle')
    elseif button == "r" then
        vim.api.nvim_command('BookmarkAnnotate')
    end
end

local builtin = require("statuscol.builtin")
local cfg = {
    setopt = true,
    relculright = true,
    ft_ignore = {
        "SidebarNvim",
        "neotest-summary",
        "toggleterm",
        "netrw",
        "dapui_console",
        "dapui_watches",
        "dapui_stacks",
        "dapui_breakpoints",
        "dapui_scopes",
        "dap-repl",
    },
    segments = {
        {
            -- Fold Markers
            text = { builtin.foldfunc },
            click = "v:lua.ScFa",
        },
        {
            -- Diagnostics
            sign = {
                namespace = { "diagnostic" },
                maxwidth = 1,
                colwidth = 1,
                auto = false,
                fillchars = ""
            },
            click = "v:lua.ScSa",
        },
        {
            -- Dap
            sign = {
                name = { "DapBreakpoint", "DapStopped", },
                maxwidth = 1,
                colwidth = 1,
                auto = false,
            },
            click = "v:lua.ScSa",
        },
        {
            sign = {
                name = { "Bookmark", "BookmarkAnnotation" },
                maxwidth = 1,
                colwidth = 1,
                auto = false,
            },
            click = "v:lua.BookmarkAction",
        },
        {
            sign = {
                namespace = { "gitsign" },
                maxwidth = 1,
                colwidth = 1,
                auto = false,
            },
            click = "v:lua.ScSa",
        },
        {
            -- Line Numbers
            text = { builtin.lnumfunc },
            click = "v:lua.ScLa",
        },
        {
            text = { " " }, -- Dummy space separator to make the UI look better
        },
    },
}

require("statuscol").setup(cfg)
