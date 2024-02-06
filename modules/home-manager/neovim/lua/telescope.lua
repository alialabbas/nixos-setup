local icons = require("nvim-nonicons")

require("telescope").setup({
    extensions = {
        file_browser = {
            hijack_netrw = true,
        },
    },
    defaults = {
        layout_strategy = "vertical",
        prompt_prefix = "  " .. icons.get("telescope") .. "  ",
        selection_caret = " ❯ ",
        entry_prefix = "   ",
    },
})

require('telescope').load_extension('ui-select')
require('telescope').load_extension('repo')
require('telescope').load_extension('file_browser')
require("telescope").load_extension("yaml_schema")
require('telescope').load_extension('vim_bookmarks')

vim.api.nvim_set_keymap(
    "n",
    "<leader>tt", ":Telescope<CR>",
    { noremap = true, silent = true })

vim.keymap.set(
    "n",
    "<leader>f",
    function() require "telescope".extensions.file_browser.file_browser({ path = vim.loop.cwd(), initial_mode = "normal" }) end,
    { noremap = true, silent = true })
