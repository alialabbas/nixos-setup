------- Global Options
vim.o.title = false -- This messes up wsl/windows-terminal
vim.o.termguicolors = true
vim.o.laststatus = 2
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.smartcase = true
vim.o.mouse = "a"
vim.o.undofile = true
vim.o.backup = true
vim.o.writebackup = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.autoread = true -- autoreload modified files
vim.o.list = true -- Show hidden characters
vim.o.t_Co = 256
vim.o.showmatch = true
vim.o.showmode = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.wop = "pum"
vim.o.syntax_on = true

------- Window Options
vim.wo.signcolumn = "yes"
vim.wo.number = true

------- Buffer Options
vim.bo.tabstop = 4
vim.bo.expandtab = true
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.shiftwidth = 4
vim.bo.autoindent = true

vim.cmd.colorscheme "onehalfdark"

------- CMDs
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*.rs", "*.nix", "*.go", "*.lua" },
    callback = function() vim.lsp.buf.format() end
})
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" },
    command = [[ :%s/\s\+$//e ]],
})

vim.cmd [[ hi Pmenu guifg=#dcdfe4 ctermfg=188 ]]
vim.cmd [[ hi Pmenu gui=NONE cterm=NONE ]]
vim.cmd [[ hi Pmenu guibg=#313640 ctermbg=237 ]]
vim.cmd [[ map <leader>y "+y ]]
vim.cmd [[ map <leader>p "+p]]

------ GENERIC KEYMAPS
vim.api.nvim_set_keymap("n", "<C-[>", ":tabprevious<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-]>", ":tabnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("c", "w!!", "%!sudo tee > /dev/null %", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>/", ":nohlsearch<CR>", { noremap = true, silent = true })

------ PLUGINS

------ TREESITTER
require "nvim-treesitter.configs".setup {
    highlight = {
        enable = true
    },
    playground = {
        enable = true,
        disable = {},
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false, -- Whether the query persists across vim sessions
        keybindings = {
            toggle_query_editor = "o",
            toggle_hl_groups = "i",
            toggle_injected_languages = "t",
            toggle_anonymous_nodes = "a",
            toggle_language_display = "I",
            focus_language = "f",
            unfocus_language = "F",
            update = "R",
            goto_node = "<cr>",
            show_help = "?",
        },
    }
}

------ TELESCOPE
local icons = require("nvim-nonicons")
require("telescope").setup({
    defaults = {
        prompt_prefix = "  " .. icons.get("telescope") .. "  ",
        selection_caret = " ❯ ",
        entry_prefix = "   ",
    },
})
require("telescope").load_extension("yaml_schema")
vim.api.nvim_set_keymap("n", "<leader>tt", ":Telescope<CR>", { noremap = true, silent = true })

------ DAP
local defaultKeymapOptions = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<F5>", ":DapContinue<CR>", defaultKeymapOptions)
vim.api.nvim_set_keymap("n", "<leader><F5>", ":DapTerminate<CR>", defaultKeymapOptions)
vim.api.nvim_set_keymap("n", "<F9>", ":DapToggleBreakpoint<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader><F9>", [[ <Esc><Cmd>lua require('dap').clear_breakpoints()<CR>]],
    { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F10>", ":DapStepOver<CR>", defaultKeymapOptions)
vim.api.nvim_set_keymap("n", "<leader><F11>", ":DapStepOut<CR>", defaultKeymapOptions)
vim.api.nvim_set_keymap("n", "<F11>", ":DapStepInto<CR>", defaultKeymapOptions)

local dap, dapui = require("dap"), require("dapui")
vim.api.nvim_set_hl(0, "DapBreakpoint", { ctermbg = 0, fg = "#993939" })
vim.api.nvim_set_hl(0, "DapLogPoint", { ctermbg = 0, fg = "#61afef" })
vim.api.nvim_set_hl(0, "DapStopped", { ctermbg = 0, fg = "#98c379" })

vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "ﳁ", texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DapLogPoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "", texthl = "DapStopped", linehl = "", numhl = "" })

dapui.setup()


dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open({})
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close({})
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close({})
end

vim.g.dotnet_build_project = function()
    local default_path = vim.fn.getcwd() .. "/"
    if vim.g["dotnet_last_proj_path"] ~= nil then
        default_path = vim.g["dotnet_last_proj_path"]
    end
    local path = vim.fn.input("Path to your *proj file", default_path, "file")
    vim.g["dotnet_last_proj_path"] = path
    local cmd = "dotnet build -c Debug " .. path .. " > /dev/null"
    print("")
    print("Cmd to execute: " .. cmd)
    local f = os.execute(cmd)
    if f == 0 then
        print("\nBuild: ✔️ ")
    else
        print("\nBuild: ❌ (code: " .. f .. ")")
    end
end

vim.g.dotnet_get_dll_path = function()
    local request = function()
        return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/net6.0", "file")
    end

    if vim.g["dotnet_last_dll_path"] == nil then
        vim.g["dotnet_last_dll_path"] = request()
    else
        if vim.fn.confirm("Do you want to change the path to dll?\n" .. vim.g["dotnet_last_dll_path"], "&yes\n&no", 2) ==
            1 then
            vim.g["dotnet_last_dll_path"] = request()
        end
    end

    return vim.g["dotnet_last_dll_path"]
end

vim.g.get_dap_args = function()
    local getUserArgs = function()
        return vim.fn.input("\nArgments to be passed to your application\n")
    end

    if vim.g["dap_args"] == nil then
        vim.g["dap_args"] = getUserArgs()
    else
        if vim.fn.confirm("Do you want to use the same args?\n" .. vim.g["dap_args"], "&yes\n&no", 2) == 1 then
            vim.g["dap_args"] = getUserArgs()
        end
    end

    return vim.g["dap_args"]
end

local config = {
    {
        type = "netcoredbg",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
            if vim.fn.confirm("Should I recompile first?", "&yes\n&no", 2) == 1 then
                vim.g.dotnet_build_project()
            end
            return vim.g.dotnet_get_dll_path()
        end,
        args = function() return vim.split(vim.g.get_dap_args(), " ") end
    },
}


dap.adapters.netcoredbg = {
    type = "executable",
    command = "netcoredbg",
    args = { "--interpreter=vscode" }
}

dap.configurations.cs = config
dap.configurations.fsharp = config

-- Go dap adapter and configurations -- TODO: could add attach request and other ones
dap.adapters.go = {
    type = "server",
    port = "${port}",
    executable = {
        command = "dlv",
        args = { "dap", "-l", "127.0.0.1:${port}" },
    },
}

dap.configurations.go = {
    {
        type = "go",
        name = "debug go.mod",
        request = "launch",
        program = "${fileDirname}",
        args = function() return vim.split(vim.g.get_dap_args(), " ") end
    },
    {
        type = "go",
        name = "Debug file",
        request = "launch",
        program = "${file}",
        args = function() return vim.split(vim.g.get_dap_args(), " ") end
    },
    {
        type = "go",
        name = "Debug test file",
        request = "launch",
        program = "${file}",
        mode = "test",
    },
    {
        type = "go",
        name = "Debug test go.mod",
        request = "launch",
        program = "${fileDirname}",
        mode = "test",
    }
}


------ NEOTEST
require("neotest").setup({
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

vim.api.nvim_set_keymap("n", "<leader>tr", [[ <Esc><Cmd>lua require('neotest').run.run()<CR> ]], defaultKeymapOptions)
vim.api.nvim_set_keymap("n", "<leader>tf", [[ <Esc><Cmd>lua require('neotest').run.run(vim.fn.expand("%"))<CR> ]],
    defaultKeymapOptions)
vim.api.nvim_set_keymap("n", "<leader>td", [[ <Esc><Cmd>lua require("neotest").run.run({strategy = "dap"})<CR> ]],
    defaultKeymapOptions)
vim.api.nvim_set_keymap("n", "<leader>ts", [[ <Esc><Cmd>lua require("neotest").summary.toggle()<CR> ]],
    defaultKeymapOptions)
vim.api.nvim_set_keymap("n", "<leader>to", [[ <Esc><Cmd>lua require("neotest").output_panel.toggle()<CR> ]],
    defaultKeymapOptions)

------ COMMENT
require("Comment").setup()

------ REFACTORING
require("refactoring").setup({})
vim.api.nvim_set_keymap("v", "<leader>re", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]],
    { noremap = true, silent = true, expr = false })
vim.api.nvim_set_keymap("v", "<leader>rf",
    [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]],
    { noremap = true, silent = true, expr = false })
vim.api.nvim_set_keymap("v", "<leader>rv", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]],
    { noremap = true, silent = true, expr = false })
vim.api.nvim_set_keymap("v", "<leader>ri", [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
    { noremap = true, silent = true, expr = false })

-- Extract block doesn't need visual mode
vim.api.nvim_set_keymap("n", "<leader>rb", [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]],
    { noremap = true, silent = true, expr = false })
vim.api.nvim_set_keymap("n", "<leader>rbf", [[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]],
    { noremap = true, silent = true, expr = false })

-- Inline variable can also pick up the identifier currently under the cursor without visual mode
vim.api.nvim_set_keymap("n", "<leader>ri", [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
    { noremap = true, silent = true, expr = false })

------ LSP
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)

local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
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
    vim.keymap.set("n", "<space>f", function() vim.lsp.buf.format { async = true } end, bufopts)
end

-- TODO: vim.tbl_extend("force", table1, table2, ...) to have a basic config and then overrides for each
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local config = {
    handlers = {
        ["textDocument/definition"] = require("omnisharp_extended").handler,
    },
    cmd = { "OmniSharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
    -- rest of your settings
    on_attach = on_attach,
    capabilities = capabilities,
}

require "lspconfig".omnisharp.setup(config)

require "lspconfig".sumneko_lua.setup {
    on_attach = on_attach,
    capabilities = capabilities,
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
}

require("lspconfig").nil_ls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        ["nil"] = {
            formatting = {
                command = { "nixpkgs-fmt" },
            },
        },
    },
}

-- Simple handler to prefix ansible file location with file scheme which what neovim client expect
local function handler(err, result, ctx, config)
    if result == nil then
        return
    end
    result[1].targetUri = "file://" .. result[1].targetUri

    return vim.lsp.handlers['textDocument/definition'](err, result, ctx, config)
end

require('lspconfig').ansiblels.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    handlers = {
        ["textDocument/definition"] = handler
    }
}


local servers = { "gopls" }
for _, lsp in ipairs(servers) do
    require("lspconfig")[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

local cfg = require("yaml-companion").setup({
    lspconfig = {
        on_attach = on_attach,
        capabilities = capabilities,
    },
})
require("lspconfig")["yamlls"].setup(cfg)


------ AUTOCOMPLETE
local cmp = require "cmp"
cmp.setup {
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
        { name = "buffer" },
        { name = 'nvim_lsp_signature_help' },
    }
}
cmp.setup.filetype({ 'xml' }, {
    sources = {
        { name = 'csproj', keyword_length = 4 },
        { name = 'vsnip' },
        { name = 'path' }
    }
})

require("cmp_git").setup()

------ SIDEBAR
local sidebar = require("sidebar-nvim")
sidebar.setup({
    open = true,
    sections = { "git", "diagnostics", "todos", "symbols", "buffers", "files", "containers" },
    todos = {
        icon = "",
        ignored_paths = { "~" },
        initially_closed = false,
    },
    files = {
        icon = "",
        show_hidden = false,
        ignored_paths = { "%.git$", "bin", "obj", "~" }
    },
    hide_statusline = true,
})

vim.keymap.set("n", "<S-B>", function() if sidebar.is_open() then sidebar.toggle() else sidebar.focus() end end)

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

------ TERMINAL
local Terminal = require("toggleterm.terminal").Terminal
require("toggleterm").setup {
    shade_terminals = false,
}

local nixrepl = Terminal:new({
    cmd = "nix repl",
    on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", opts)
    end,
    on_close = function(term)
        vim.cmd("startinsert!")
    end,
})

vim.api.nvim_create_user_command("NixRepl", function() nixrepl:toggle() end, { nargs = 0 })

-- Terminal keymaps
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts) -- sane people mapping to go out of focus
vim.keymap.set("n", "<C-T>", ":ToggleTerm<CR>", opts)


----- STATUSLINE
require("lualine").setup({
    options = {
        disabled_filetypes = {
            statusline = {
                "SidebarNvim",
            }
        },
    },
    extensions = { 'nvim-dap-ui' }
})



----- CSPROJ CMP SORUCE
-- works fine but version is a bit flaky when I don't want the search to happen before I have 4 numbers
-- I could get around that by writing a second source but I need to see if it possible to that first
local source = {}

---Return whether this source is available in the current context or not (optional).
---@return boolean
function source:is_available()
    local filename = vim.fn.expand('%:t')
    return string.match(filename, '.csproj$')
end

---Return the debug name of this source (optional).
---@return string
function source:get_debug_name()
    return 'csproj'
end

---Return trigger characters for triggering completion (optional).
function source:get_trigger_characters()
    return { '.' }
end

local Job = require "plenary.job"
---Invoke completion (required).
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
    local cur_line = params.context.cursor_line
    local cur_col = params.context.cursor.col

    local packageRef = string.find(cur_line, 'ProjectReference')
    if packageRef ~= nil then return end -- we are on a package ref element, ignore it

    local nuget_name = string.match(cur_line, 'Include="([^"]*)') -- capture the string after include only

    if nuget_name == nil then return end -- we need at least an include tag to do something useful here
    local find_version = false

    local _, versionCol = string.find(cur_line, "Version")
    if versionCol ~= nil and cur_col >= versionCol then
        find_version = true
    end
    if find_version == false then
        Job:new {
            command = "nugetSearch",
            args = { nuget_name },
            on_exit = function(job)
                local items = {}
                for _, nuget in ipairs(job:result()) do
                    table.insert(items, { label = nuget })
                end
                callback(items)
            end,
        }:sync()
    else
        Job:new {
            command = "nugetVersions",
            args = { nuget_name },
            on_exit = function(job)
                local items = {}
                for _, version in ipairs(job:result()) do
                    table.insert(items, { label = version })
                end
                callback(items)
            end,
        }:sync()
    end
end

---Register your source to nvim-cmp.
require('cmp').register_source('csproj', source)
