local telescope = require('telescope.builtin')
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<space>q", telescope.diagnostics --[[ vim.diagnostic.setloclist ]], opts)

local signs = { Error = '󰅚 ', Warn = '󰀪 ', Hint = '󰌶 ', Info = '󰋽 ' }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl })
end

vim.diagnostic.config({
    virtual_text = false,
})

-- TODO: check file type then from the file type we just change the ccommand for certain things for telescope csharp files
local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    if client.name == "omnisharp" then
        vim.keymap.set('n', 'gd', ":lua require('omnisharp_extended').telescope_lsp_definitions()<CR>", bufopts)
    else
        vim.keymap.set("n", "gd", ":Telescope lsp_definitions<CR>", bufopts)
    end
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
    vim.keymap.set("n", "gi", telescope.lsp_implementations --[[ vim.lsp.buf.implementation ]], bufopts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set("n", "<space>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
    vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
    vim.keymap.set("n", "gr", ":Telescope lsp_references<CR>", bufopts)
    vim.keymap.set("n", "<space>f", function() vim.lsp.buf.format { async = true } end, bufopts)

    -- TODO: double check if Omnisharp fixed this issue in the latest version
    -- TODO: also check if inlay hints is enabled in omnisharp right now
    -- client.server_capabilities.semanticTokensProvider = nil
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}

local defaults = {
    on_attach = on_attach,
    capabilities = capabilities,
}

-- Simple handler to prefix ansible file location with file scheme which what neovim client expect
local function ansible_handler(err, result, ctx, config)
    if result == nil then
        return
    end
    result[1].targetUri = "file://" .. result[1].targetUri

    return vim.lsp.handlers['textDocument/definition'](err, result, ctx, config)
end

local servers = {
    bashls = {},
    gopls = {},
    jsonnet_ls = {},
    pyright = {},
    fsautocomplete = {
        cmd = { 'fsautocomplete', },
        cmd_env = { DOTNET_ROLL_FORWARD = "LatestMajor" },
    },
    rust_analyzer = {},
    omnisharp = {
        handlers = {
            ["textDocument/definition"] = require("omnisharp_extended").handler,
        },
        cmd = { "OmniSharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
    },
    lua_ls = {
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                },
                diagnostics = {
                    globals = { "vim" },
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                },
                format = {
                    enable = true,
                    defaultConfig = {
                        indent_style = "space",
                        indent_size = "4",
                    },
                },
                telemetry = {
                    enable = false,
                },
            },
        },
    },
    nil_ls = {
        settings = {
            ["nil"] = {
                formatting = {
                    command = { "nixpkgs-fmt" },
                },
            },
        },
    },
    ansiblels = {
        handlers = {
            ["textDocument/definition"] = ansible_handler
        },
    },
    pylsp = {
        settings = {
            pylsp = {
                plugins = {
                    ruff = {
                        enabled = true,
                        extendSelect = { "I" },
                    },
                }
            }
        }
    },
    helm_ls = {
        settings = {
            ['helm-ls'] = {
                yamlls = {
                    path = "yaml-language-server",
                }
            }
        },
    },
    yamlls = require("yaml-companion").setup({
        lspconfig = defaults,
    }),
    efm = {
        init_options = { documentFormatting = true },
        filetypes = { "sh", "json", "markdown", "dockerfile" },
        settings = {
            languages = {
                sh = {
                    {
                        formatCommand = 'shfmt -ci -s -bn',
                        formatStdin = true,
                        lintCommand = 'shellcheck -f gcc -x',
                        lintSource = 'shellcheck',
                        lintFormats = { '%f:%l:%c: %trror: %m', '%f:%l:%c: %tarning: %m', '%f:%l:%c: %tote: %m' }
                    }
                },
                json = {
                    {
                        lintCommand = 'jq .',
                        formatCommand = 'jq .',
                        formatStdin = true,
                        lintStdin = true,
                        lintOffset = 1,
                        lintFormats = { '%m at line %l, column %c', },
                    },
                },
                markdown = {
                    {
                        lintCommand = "markdownlint -s",
                        lintSource = "markdownlint",
                        lintStdin = true,
                        lintFormats = { '%f:%l %m', '%f:%l:%c %m', '%f: %l: %m' },
                    },
                },
                dockerfile = {
                    {
                        lintCommand = 'hadolint --no-color',
                        lintFormats = { '%f:%l %m' },
                    }
                },
            }
        }
    }
}

for server, config in pairs(servers) do
    require("lspconfig")[server].setup(vim.tbl_extend("force", defaults, config))
end


vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*.rs", "*.nix", "*.go", "*.lua" },
    callback = function() vim.lsp.buf.format() end
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" },
    command = [[ :%s/\s\+$//e ]],
})
