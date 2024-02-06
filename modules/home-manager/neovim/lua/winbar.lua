vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = { '*' },
    callback = function()
        require("dropbar").setup({
            menu = {
                keymaps = {
                    ['<esc>'] = function()
                        local menu = require('dropbar.utils').menu.get_current()
                        if menu then
                            menu:close()
                        end
                    end,
                },
            },
        })
        vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE", fg = "NONE" })
        vim.api.nvim_set_hl(0, "WinBarNC", { bg = "NONE", fg = "NONE" })
        vim.keymap.set("n", "<leader>bc", require("dropbar.api").pick, { noremap = true, silent = true })
    end
})
