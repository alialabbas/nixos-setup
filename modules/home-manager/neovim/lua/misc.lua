require("onedarkpro").setup({
    highlights = {
        TabLineIn = { bg = '#abb2bf', fg = '#282c34' },
        TabLineHead = { fg = '#282c34', bg = '#61afef' },
        TabFill = { bg = "#282c34" },
        TabLineSel = { fg = '#282c34', bg = '#61afef' },
    },
})
vim.cmd.colorscheme "onedark"

require "nvim-treesitter.configs".setup {
    indent = {
        enable = false,
    },
    highlight = {
        enable = true
    },
    ensure_installed = {},
}

require("dressing").setup({
    input = {
        relative = "editor",
        winhighlight = "FloatTitle:Normal", -- fix float title visibilty
    }
})

------ NEOGEN
require("neogen").setup {
    languages = {
        cs = {
            template = {
                annotation_convention = "xmldoc"
            },
        },
    },
}

require('gitsigns').setup({
    signs = {
        add    = { text = '+', },
        change = { text = '~', },
        delete = { text = '-', },
    },
    numhl = false,
    linehl = false,
    signcolumn = true,
})


vim.g.netrw_liststyle = 3
vim.g.netrw_banner = 0

require("gitlinker").setup({
    callbacks = {
        ["gitlab"] = require "gitlinker.hosts".get_gitlab_type_url
    }
})

require("oil").setup()

-- Setup menu for easier navigation
vim.keymap.set({ "v", "n" }, "<F22>", "<cmd>:popup Lsp<CR>")

vim.cmd [[:amenu 500.400 PopUp.Lsp <cmd>:popup Lsp<CR> ]] -- Always the top menu
vim.cmd [[:amenu 500.401 PopUp.Back <cmd>:execute "normal <C-o>"<CR> ]]
vim.cmd [[:amenu 10.100 Lsp.Definition <cmd>:lua = vim.lsp.buf.definition()<CR>]]
vim.cmd [[:amenu 10.110 Lsp.Peek\ Definition <cmd>:lua = vim.lsp.buf.hover()<CR>]]
vim.cmd [[:amenu 10.120 Lsp.Type\ Definition <cmd>:lua vim.lsp.buf.type_definition()<CR>]]
vim.cmd [[:amenu 10.130 Lsp.Implementations <cmd>:lua vim.lsp.buf.implementation<CR>]]
vim.cmd [[:amenu 10.140 Lsp.References <cmd>:lua vim.lsp.buf.references()<CR>]]
vim.cmd [[:amenu 10.150 Lsp.ToggleInlayHint <cmd>: lua vim.lsp.inlay_hint.enable()<CR>]]
-- vim.cmd [[:amenu 10.150 Lsp.-sep- *]]
vim.cmd [[:amenu 10.160 Lsp.Rename <cmd>:lua = vim.lsp.buf.rename()<CR>]]
vim.cmd [[:amenu 10.170 Lsp.Code\ Actions <cmd>:lua = vim.lsp.buf.code_action()<CR>]]
