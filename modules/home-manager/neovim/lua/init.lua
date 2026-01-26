-- Core Configuration
require("options")
require("keymaps")

-- Plugin Configurations
vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
    once = true,
    callback = function()
        require("plugins.cmp")
    end,
})
require("plugins.dap")
require("diff")
require("fold")
require("ft")
require("misc")
require("rooter")
require("sessions")
require("statuscolumn")
require("statusline")
require("tabline")
require("plugins.telescope")
require("terminal")
require("winbar")
require("wsl")
require("zoom")

-- Diagnostics Config
local telescope = require('telescope.builtin')
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
vim.keymap.set("n", "<space>q", telescope.diagnostics, opts)

vim.diagnostic.config({
    virtual_text = false,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰌶 ',
            [vim.diagnostic.severity.HINT] = '󰋽 ',
        },
        linehl = {
            [vim.diagnostic.severity.ERROR] = "Error",
            [vim.diagnostic.severity.WARN] = "Warn",
            [vim.diagnostic.severity.INFO] = "Info",
            [vim.diagnostic.severity.HINT] = "Hint",
        },
    },
})

-- Global LSP Capabilities (cmp-nvim-lsp)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}

vim.lsp.config("*", {
    capabilities = capabilities,
})

-- Global LspAttach Autocommand (Keymaps & Settings)
vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP actions",
    callback = function(event)
        local bufnr = event.buf
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        local bufopts = { noremap = true, silent = true, buffer = bufnr }

        if client == nil then
            vim.print("FATAL: Nil client")
            return
        end

        -- 1. Options
        vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })
        if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_set_option_value("formatexpr", "v:lua.vim.lsp.formatexpr()", { buf = bufnr })
        end

        -- 2. Keymaps
        if client.name == "omnisharp" then
            vim.keymap.set('n', 'gd', ":lua require('omnisharp_extended').telescope_lsp_definitions()<CR>", bufopts)
        else
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
        end
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
        vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
        vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
        vim.keymap.set("n", "<space>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts)
        vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
        vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
        vim.keymap.set({ "n", "v" }, "<space>f", function() vim.lsp.buf.format { async = true } end, bufopts)

        -- 3. Inlay Hints
        if client.server_capabilities.inlayHintProvider or client.name == "omnisharp" then
            if vim.lsp.inlay_hint then
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

                local group = vim.api.nvim_create_augroup("LspInlayHints_" .. bufnr, { clear = true })
                vim.api.nvim_create_autocmd("InsertEnter", {
                    buffer = bufnr,
                    group = group,
                    callback = function() vim.lsp.inlay_hint.enable(false, { bufnr = bufnr }) end,
                })
                vim.api.nvim_create_autocmd("InsertLeave", {
                    buffer = bufnr,
                    group = group,
                    callback = function() vim.lsp.inlay_hint.enable(true, { bufnr = bufnr }) end,
                })
            end
        end
    end,
})

-- Enable Servers
-- Neovim will automatically load configuration from `lsp/<server>.lua`
local servers = {
    "bashls",
    "clangd",
    "nickel_ls",
    "gopls",
    "jsonnet_ls",
    "pyright",
    "fsautocomplete",
    "rust_analyzer",
    "emmylua_ls",
    "nixd",
    "ansiblels",
    "pylsp",
    "helm_ls",
    "yamlls",
    "efm",
    "roslyn_ls",
}
vim.lsp.enable(servers)

-- General Autocommands
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*.rs", "*.nix", "*.go", "*.lua" },
    callback = function() vim.lsp.buf.format() end
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" },
    command = [[ :%s/\s\+$//e ]],
})

require("fidget").setup()
