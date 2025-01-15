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
    vim.keymap.set({ "n", "v" }, "<space>f", function() vim.lsp.buf.format { async = true } end, bufopts)

    -- omnisharp is special, doesn't believe in returning server_capabilities
    if client.server_capabilities.inlayHintProvider or client.name == "omnisharp" then
        vim.lsp.inlay_hint.enable()

        vim.api.nvim_create_autocmd('InsertEnter', {
            buffer = bufnr,
            callback = function()
                vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
            end,
        })
        vim.api.nvim_create_autocmd('InsertLeave', {
            buffer = bufnr,
            callback = function()
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end,
        })
    end

    if client.server_capabilities.documentFormattingProvider == true then
        vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
    end
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
    clangd = {},
    nickel_ls = {},
    gopls = {
        settings = {
            gopls = {
                ["ui.inlayhint.hints"] = {
                    compositeLiteralFields = true,
                    constantValues = true,
                    parameterNames = true
                },
            },
        },
    },
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
        cmd = {
            "OmniSharp",
            "RoslynExtensionsOptions:InlayHintsOptions:EnableForParameters=true",
            "RoslynExtensionsOptions:InlayHintsOptions:ForLiteralParameters=true",
            "RoslynExtensionsOptions:InlayHintsOptions:ForIndexerParameters=true",
            "RoslynExtensionsOptions:InlayHintsOptions:ForObjectCreationParameters=true",
            "RoslynExtensionsOptions:InlayHintsOptions:EnableForTypes=true",
            "RoslynExtensionsOptions:InlayHintsOptions:ForImplicitVariableTypes=true",
            "RoslynExtensionsOptions:InlayHintsOptions:ForLambdaParameterTypes=true",
            "RoslynExtensionsOptions:InlayHintsOptions:ForImplicitObjectCreation=true",
            "--languageserver",
            "--hostPID",
            tostring(vim.fn.getpid()) },
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
                hint = {
                    enable = true,
                    setType = true,
                },
            },
        },
    },
    -- For nix, I want to use two servers, nixd for all things autocompletion and selection workspace settings
    -- nil_ls has useful code action and good nix docs compared to nixd right now
    nixd = {
        handlers = {
            ["textDocument/hover"] = function() end,
        },
        -- settings = {
        --     ['nixd'] = {
        --         eval = {
        --             depth = 10,
        --         },
        --         formatting = {
        --             command = "nixpkgs-fmt",
        --         },
        --         options = {
        --             enable = true,
        --             target = {
        --                 args = {},
        --                 installable = ".#nixosConfigurations.framework.options",
        --             },
        --         },
        --     },
        -- },
    },
    nil_ls = {
        on_init = function(client)
            client.server_capabilities.completionProvider = nil
            client.server_capabilities.semanticTokensProvider = nil
        end,
        handlers = {
            ["textDocument/completion"] = function() vim.notify_once("nil_ls turned off and won't generated completion") end,
        },
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

-- This is more of a UI thing, I think mostly what I care about is a simple way to request the status to the notification system rather than just keeping the update happening all the time like how everyone is doing
require("fidget").setup()

vim.api.nvim_create_autocmd({ 'FileType', }, {
    pattern = "nix",
    callback = function(args)
        local update_nixd_settings = function()
            local cfgs = {}

            local merge_cfgs = function(_, data, event)
                if event == "stdout" and data then
                    local table_cfg = vim.json.decode(data[1])
                    for _, home_cfg in ipairs(table_cfg) do
                        table.insert(cfgs, "homeConfigurations." .. home_cfg)
                    end
                end
            end

            local on_event = function(job_id, data, event)
                if event == "stdout" and data then
                    local nixos_cfgs = vim.json.decode(data[1])
                    for _, nixos_cfg in ipairs(nixos_cfgs) do
                        table.insert(cfgs, "nixosConfigurations." .. nixos_cfg)
                    end

                    vim.ui.select(cfgs, { label = '> ' }, function(choice)
                        local settings = {
                            ['nixd'] = {
                                eval = {
                                    depth = 10,
                                },
                                formatting = {
                                    command = "nixpkgs-fmt",
                                },
                                options = {
                                    enable = true,
                                    target = {
                                        args = {},
                                        installable = string.format(".#%s.options", choice),
                                    },
                                },
                            },
                        }

                        for _, client in ipairs(vim.lsp.get_clients({ name = "nixd" })) do
                            local result = client.notify("workspace/didChangeConfiguration",
                                {
                                    settings = settings,
                                }
                            )
                            vim.notify("updated config " .. tostring(result));
                            client.config.settings = settings
                        end
                    end)
                end
            end

            local job_id = vim.fn.jobstart('nix eval .#homeConfigurations --apply builtins.attrNames --json',
                { on_stdout = merge_cfgs, stdout_buffered = true })

            vim.fn.jobwait({ job_id })

            vim.fn.jobstart('nix eval .#nixosConfigurations --apply builtins.attrNames --json',
                { on_stdout = on_event, stdout_buffered = true })
        end

        vim.api.nvim_create_user_command("NixUpdateSettings", update_nixd_settings, {})
        vim.api.nvim_del_autocmd(args.id)
    end
})
