require("onedarkpro").setup({
    highlights = {
        TabLineIn = { bg = '#abb2bf', fg = '#282c34' },
        TabLineHead = { fg = '#282c34', bg = '#61afef' },
        TabFill = { bg = "#282c34" },
        TabLineSel = { fg = '#282c34', bg = '#61afef' },
    }
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

require 'treesitter-context'.setup {
    enable = false,
}

vim.g.rooter_cd_cmd = 'tcd'
vim.g.rooter_patterns = {
    '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile',
    'package.json', 'go.mod', '*.sln' }

require("dressing").setup({
    input = {
        relative = "editor",
        winhighlight = "FloatTitle:Normal", -- fix float title visibilty
    }
})

------ NEOTEST
require("neotest").setup({
    status = {
        signs = false,
        virtual_text = true,
    },
    adapters = {
        require("neotest-dotnet"),
        require("neotest-go")({
            experimental = {
                test_table = true,
            },
            args = { "-count=1", "-timeout=60s" }
        })
    }
})

local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap(
    "n",
    "<leader>tr",
    [[ <Esc><Cmd>lua require('neotest').run.run()<CR> ]],
    opts)

vim.api.nvim_set_keymap(
    "n",
    "<leader>tf",
    [[ <Esc><Cmd>lua require('neotest').run.run(vim.fn.expand("%"))<CR> ]],
    opts)

vim.api.nvim_set_keymap(
    "n",
    "<leader>td",
    [[ <Esc><Cmd>lua require("neotest").run.run({strategy = "dap"})<CR> ]],
    opts)

vim.api.nvim_set_keymap(
    "n",
    "<leader>ts",
    [[ <Esc><Cmd>lua require("neotest").summary.toggle()<CR> ]],
    opts)

vim.api.nvim_set_keymap(
    "n",
    "<leader>to",
    [[ <Esc><Cmd>lua require("neotest").output_panel.toggle()<CR> ]],
    opts)

------ COMMENT
require("Comment").setup()

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
        add    = { hl = 'GitSignsAdd', text = '+', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
        change = { hl = 'GitSignsChange', text = '~', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
        delete = { hl = 'GitSignsDelete', text = '-', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
    },
})


vim.g.netrw_liststyle = 3
vim.g.netrw_banner = 0

require("gitlinker").setup({
    callbacks = {
        ["gitlab"] = require "gitlinker.hosts".get_gitlab_type_url
    }
})

require("oil").setup()

require("markview").setup({
    modes = { "n", "no", "c" }, -- Change these modes
    -- to what you need

    hybrid_modes = { "" }, -- Uses this feature on
    -- normal mode

    -- This is nice to have
    callbacks = {
        on_enable = function(_, win)
            vim.wo[win].conceallevel = 2;
            vim.wo[win].concealcursor = "c";
        end
    }
})

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
