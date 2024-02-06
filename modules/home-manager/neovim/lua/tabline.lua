vim.api.nvim_set_hl(0, "TabLineIn", { bg = '#abb2bf', fg = '#282c34' })
vim.api.nvim_set_hl(0, "TabLineHead", { fg = '#282c34', bg = '#61afef' })
vim.api.nvim_set_hl(0, "TabFill", { bg = "#282c34" })
vim.api.nvim_set_hl(0, "TabLineSel", { fg = '#282c34', bg = '#61afef' })

require("tabby").setup()
vim.api.nvim_create_autocmd({ "DirChanged" }, {
    callback = function(args)
        local tab_name = vim.fn.fnamemodify(args.file, ":t")
        require 'tabby'.tab_rename(tab_name)
    end,
})

local function tab_modified(tab)
    local wins = require("tabby.module.api").get_tab_wins(tab)
    for _, x in pairs(wins) do
        if vim.bo[vim.api.nvim_win_get_buf(x)].modified then
            return ""
        end
    end
    return ""
end

local theme = {
    fill = 'TabFill',
    head = 'TabLineHead',
    current_tab = 'TabLineSel',
    inactive_tab = 'TabLineIn',
    tab = 'TabLine',
    win = 'TabLineHead',
    tail = 'TabLineHead',
}

require('tabby.tabline').set(function(line)
    return {
        {
            { '  ', hl = theme.head },
            line.sep('', theme.head, theme.fill),
        },
        line.tabs().foreach(function(tab)
            local hl = tab.is_current() and theme.current_tab or theme.inactive_tab
            return {
                line.sep('', hl, theme.fill),
                tab.number(),
                "",
                tab.name(),
                "",
                tab_modified(tab.id),
                line.sep('', hl, theme.fill),
                hl = hl,
                margin = ' ',
            }
        end),
        line.spacer(),
        {
            line.sep('', theme.tail, theme.fill),
            { '  ', hl = theme.tail },
        },
        hl = theme.fill,
    }
end)
