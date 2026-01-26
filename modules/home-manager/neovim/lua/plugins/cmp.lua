local cmp = require "cmp"
cmp.setup {
    enabled = function()
        -- Disable completion in comments
        local context = require("cmp.config.context")
        -- Keep command mode completion enabled
        if vim.api.nvim_get_mode().mode == "c" then
            return true
        else
            return not context.in_treesitter_capture("comment")
                and not context.in_syntax_group("Comment")
        end
    end,
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
            local icon = require("nvim-nonicons").get(vim_item.kind)
            vim_item.kind = string.format("%s %s", icon, vim_item.kind)
            vim_item.menu = ({
                nvim_lsp = "[LSP]",
                vsnip = "[Snippet]",
                path = "[Path]",
                nvim_lua = "[Lua]",
                git = "[Git]",
                conventionalcommits = "[Commit]",
                nvim_lsp_signature_help = "[Sig]",
                buffer = "[Buffer]",
            })[entry.source.name]
            return vim_item
        end,
    },
    experimental = {
        ghost_text = true,
    },
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete({ select = true }),
        ["<C-e>"] = cmp.mapping.close(),
        ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = {
        { name = "nvim_lsp" },
        { name = "vsnip" },
        { name = "path" },
        { name = "nvim_lua" },
        { name = "git" },
        { name = "conventionalcommits" },
        { name = 'nvim_lsp_signature_help' },
    }
}

-- Search mode
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = 'buffer' } }
})

-- Command mode
-- This code is left as a reminder why we don't use it.
-- CMP can't support special vars %, # which is why we don't use it
-- cmp.setup.cmdline(':', {
--     mapping = cmp.mapping.preset.cmdline(),
--     sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } })
-- })

cmp.setup.filetype({ 'xml' }, {
    sources = {
        { name = 'csproj', keyword_length = 4 },
        { name = 'vsnip' },
        { name = 'path' }
    }
})
cmp.setup.filetype({ 'markdown', 'text' }, {
    sources = {
        { name = 'buffer' },
    }
})

require("cmp_git").setup()
