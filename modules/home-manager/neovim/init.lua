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
vim.o.list = true     -- Show hidden characters
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

-- WSL is special, set the browser to wslview. NOTE: we are not using $WSL_ENV since that is not set in wslg apps
if vim.cmd.WSL_DISTOR_NAME ~= nil then
    vim.g.netrw_browsex_viewer = "wslview"
end
--vim.cmd [[ autocmd BufRead,BufNewFile */templates/*.yaml,*/templates/*.tpl,*.gotmpl,helmfile*.yaml set ft=helm ]]
--vim.cmd [[ autocmd FileType helm setlocal commentstring={{/*\ %s\ */}} ]]

------ GENERIC KEYMAPS
vim.api.nvim_set_keymap("n", "<C-C>", ":tabclose<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-[>", ":tabprevious<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-]>", ":tabnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("c", "w!!", "%!sudo tee > /dev/null %", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>/", ":nohlsearch<CR>", { noremap = true, silent = true })
vim.api.nvim_del_keymap("n", "<ESC>")

------ PLUGINS

------ TREESITTER
require "nvim-treesitter.configs".setup {
    indent = {
        enable = false,
    },
    highlight = {
        enable = true
    },
    ensure_installed = {},
    playground = {
        enable = true,
        disable = {},
        updatetime = 25,         -- Debounced time for highlighting nodes in the playground from source code
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

vim.cmd [[ set foldmethod=expr ]]
vim.cmd [[ set foldexpr=nvim_treesitter#foldexpr() ]]
vim.cmd [[ set nofoldenable ]]
vim.opt.foldcolumn = "1"
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:,diff:/]]

------ TELESCOPE
local icons = require("nvim-nonicons")
require("telescope").setup({
    defaults = {
        prompt_prefix = "  " .. icons.get("telescope") .. "  ",
        selection_caret = " ❯ ",
        entry_prefix = "   ",
    },
})
require('telescope').load_extension('ui-select')
require("telescope").load_extension("yaml_schema")
require("dressing").setup({
    input = {
        relative = "editor",
        winhighlight = "FloatTitle:Normal", -- fix float title visibilty
    }
})

vim.api.nvim_set_keymap("n", "<leader>tt", ":Telescope<CR>", { noremap = true, silent = true })

------ DAP
local defaultKeymapOptions = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<F5>", ":DapContinue<CR>", defaultKeymapOptions)
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

local currWorkspace = vim.fn.getcwd()
dap.listeners.after.event_initialized["dapui_config"] = function()
    vim.api.nvim_set_current_dir(currWorkspace)
    require("sidebar-nvim").close()
    require("neotest").summary.close()
    dapui.open({})
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    vim.api.nvim_set_current_dir(currWorkspace)
    require("dap").repl.close()
    dapui.close({})
end
dap.listeners.before.event_exited["dapui_config"] = function()
    vim.api.nvim_set_current_dir(currWorkspace)
    require("sidebar-nvim").open()
    require("dap").repl.close()
    dapui.close({})
end


vim.g.dotnet_build_project = function()
    return coroutine.create(function(dap_run_co)
        local result = vim.fn.system({ 'find', '.', '-name', '*.csproj' })
        local items = vim.split(result, "\n")

        vim.ui.select(items, { label = '> ' }, function(choice)
            local cmd = "dotnet build -c Debug " .. choice .. " > /dev/null"
            print("")
            print("Cmd to execute: " .. cmd)
            local f = os.execute(cmd)
            if f == 0 then
                print("\nBuild: ✔️ ")
            else
                print("\nBuild: ❌ (code: " .. f .. ")")
                return
            end

            result = vim.fn.system({ 'find', '.', '-name', '*.dll', '-not', '-path', '**/obj/*' })
            items = vim.split(result, "\n")
            vim.ui.select(items, { label = '> ' }, function(choice)
                coroutine.resume(dap_run_co, choice)
            end)
        end)
    end)
end


vim.g.get_dap_args = function()
    return coroutine.create(function(dap_run_co)
        if vim.g["dap_args"] ~= nil then
            vim.ui.select({ "yes", "no" }, { prompt = "Do you want to use the same args", label = ">" },
                function(choice)
                    if choice == "yes" then
                        coroutine.resume(dap_run_co, vim.split(vim.g["dap_args"], " "))
                    else
                        vim.ui.input({
                            prompt = "Enter Arguments:",
                        }, function(input)
                            vim.g["dap_args"] = input
                            local args = vim.split(input, " ")
                            coroutine.resume(dap_run_co, args)
                        end)
                    end
                end)
        else
            vim.ui.input({
                prompt = "Enter Arguments:",
            }, function(input)
                vim.g["dap_args"] = input
                local args = vim.split(input, " ")
                coroutine.resume(dap_run_co, args)
            end)
        end
    end)
end


local config = {
    {
        type = "netcoredbg",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
            return vim.g.dotnet_build_project()
        end,
        args = function() return vim.g.get_dap_args() end
    },
    {
        type = "netcoredbg",
        name = "attach - netcoredbg",
        request = "attach",
        processId = require 'dap.utils'.pick_process,
    }
}


dap.adapters.netcoredbg = {
    type = "executable",
    command = "netcoredbg",
    args = { "--interpreter=vscode" }
}

dap.configurations.cs = config

dap.adapters.go = {
    type = "server",
    port = "${port}",
    executable = {
        command = "dlv",
        args = { "dap", "-l", "127.0.0.1:${port}" },
    },
}

local get_go_mod = function(path)
    return coroutine.create(function(dap_run_co)
        local result = vim.fn.system({ 'find', path, '-name', 'go.mod' }) -- this could be replaced vim.fn.glob
        local items = vim.split(result, '\n')

        vim.ui.select(items, { label = '>' }, function(choice)
            local dir = vim.fn.fnamemodify(choice, ":p:h")
            vim.api.nvim_set_current_dir(dir)
            coroutine.resume(dap_run_co, "${fileDirname}")
        end)
    end)
end

dap.configurations.go = {
    {
        type = "go",
        name = "debug go.mod",
        request = "launch",
        program = function() return get_go_mod('.') end,
        args = function() return vim.g.get_dap_args() end
    },
    {
        type = "go",
        name = "Debug file",
        request = "launch",
        program = "${file}",
        args = function() return vim.g.get_dap_args() end
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
        program = function() return get_go_mod('.') end,
        mode = "test",
    }
}

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

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl })
end

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
    vim.keymap.set("n", "gr", ":Telescope lsp_references<CR>", bufopts)
    vim.keymap.set("n", "<space>f", function() vim.lsp.buf.format { async = true } end, bufopts)

    client.server_capabilities.semanticTokensProvider = nil
end

-- TODO: vim.tbl_extend("force", table1, table2, ...) to have a basic config and then overrides for each
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local config = {
    handlers = {
        ["textDocument/definition"] = require("omnisharp_extended").handler,
    },
    cmd = { "OmniSharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
    on_attach = on_attach,
    capabilities = capabilities,
}

require "lspconfig".omnisharp.setup(config)

require "lspconfig".lua_ls.setup {
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

require('lspconfig').pylsp.setup {
    on_attach = on_attach,
    capabilities = capabilities,
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
}

local servers = { "gopls", "helm_ls", "jsonnet_ls", "pyright" }
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
require("nvim-navic").setup({
    icons = {
        File = ' ',
        Module = ' ',
        Namespace = ' ',
        Package = ' ',
        Class = ' ',
        Method = ' ',
        Property = ' ',
        Field = ' ',
        Constructor = ' ',
        Enum = ' ',
        Interface = ' ',
        Function = ' ',
        Variable = ' ',
        Constant = ' ',
        String = ' ',
        Number = ' ',
        Boolean = ' ',
        Array = ' ',
        Object = ' ',
        Key = ' ',
        Null = ' ',
        EnumMember = ' ',
        Struct = ' ',
        Event = ' ',
        Operator = ' ',
        TypeParameter = ' '
    },

    lsp = {
        auto_attach = true,
    },
    click = true,
})

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
    open = false,
    sections = { "git", "todos", "files" },
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
    bindings = { ["q"] = function() require("sidebar-nvim").close() end },
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
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", opts)
    end,
})

vim.api.nvim_create_user_command("NixRepl", function() nixrepl:toggle() end, { nargs = 0 })

local getfile = function()
    local currbuf = vim.api.nvim_buf_get_name(0)
    return "glow " .. currbuf
end
local rendermd = Terminal:new({
    cmd = getfile(),
    direction = "tab",
    start_in_insert = false,
    close_on_exit = false,
    on_open = function(term)
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", opts)
    end,
})
vim.api.nvim_create_user_command("RenderMD", function() rendermd:toggle() end, { nargs = 0 })

-- Terminal keymaps
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts) -- sane people mapping to go out of focus
vim.keymap.set("n", "<C-T>", ":ToggleTerm<CR>", opts)


----- STATUSLINE
require("lualine").setup({
    sections = {
        lualine_c = {
            {
                'filename',
                path = 1,
                -- takes a function that is called when component is clicked with mouse.
                on_click = function(_nb_of_clicks, _button, _modifiers)
                    local filename = vim.fn.getreg('%')
                    vim.cmd("call provider#clipboard#Call('set', [ ['" ..
                        filename .. "'], 'v','\"'])")
                end,
            },
        },
        lualine_b = {
            {
                'branch',
                on_click = function(_nb_of_clicks, _button, _modifiers)
                    vim.cmd("Telescope git_branches")
                end
            },
            {
                'diff',
                on_click = function(_nb_of_clicks, _button, _modifiers)
                    vim.cmd("Telescope git_status")
                end
            },
            {
                'diagnostics',
                sources = { 'nvim_diagnostic' },
                on_click = function(_nb_of_clicks, _button, _modifiers)
                    vim.cmd("Telescope diagnostics")
                end
            },
        },
        lualine_x = { 'encoding', 'fileformat',
            {
                'filetype',
                on_click = function(_nb_of_clicks, _button, _modifiers)
                    vim.cmd("Telescope filetypes")
                end
            }
        },
    },
    options = {
        disabled_filetypes = {
            statusline = {
                "SidebarNvim",
            }
        },
    },
    extensions = { 'nvim-dap-ui', 'toggleterm', 'fugitive', 'quickfix', }
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
    if packageRef ~= nil then return end                          -- we are on a package ref element, ignore it

    local nuget_name = string.match(cur_line, 'Include="([^"]*)') -- capture the string after include only

    if nuget_name == nil then return end                          -- we need at least an include tag to do something useful here
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

_G.BookmarkAction = function(minwid, clicks, button, mods)
    -- Works nice, now all I have left is to hook into other mouse keys to make it support annotate

    local mPos = vim.fn.getmousepos()
    vim.api.nvim_command(string.format("%d", mPos.line))

    if button == "l" then
        vim.api.nvim_command('BookmarkToggle')
    elseif button == "r" then
        vim.api.nvim_command('BookmarkAnnotate')
    end
end


---Register your source to nvim-cmp.
require('cmp').register_source('csproj', source)

local builtin = require("statuscol.builtin")
cfg = {
    setopt = true,
    relculright = true,
    ft_ignore = {
        "SidebarNvim",
        "neotest-summary",
        "toggleterm",
        "netrw",
        "dapui_console",
        "dapui_watches",
        "dapui_stacks",
        "dapui_breakpoints",
        "dapui_scopes",
        "dap-repl",
    },
    segments = {
        {
            -- Fold Markers
            text = { builtin.foldfunc },
            click = "v:lua.ScFa",
        },
        -- {
        --     text = { " " },
        -- },
        {
            -- Diagnostics
            sign = { name = { "Diagnostic" }, maxwidth = 1, colwidth = 1, auto = false, fillchars = "" },
            click = "v:lua.ScSa",
        },
        {
            -- Dap
            sign = {
                name = { "DapBreakpoint", "DapStopped", },
                maxwidth = 1,
                colwidth = 1,
                auto = false,
                fillchars = ""
            },
            click = "v:lua.ScSa",
        },
        {
            -- Line Numbers
            text = { builtin.lnumfunc },
            click = "v:lua.ScLa",
        },
        -- {
        --     text = { " " }, -- Dummy space separator to make the UI look better
        -- },
        {
            -- gosh all I want is a good way to annotate and know what got annotated and the reason, something sensible
            sign = {
                name = { "Bookmark", "BookmarkAnnotation" },
                maxwidth = 1,
                colwidth = 1,
                auto = false,
            },
            click = "v:lua.BookmarkAction",
        },
        {
            -- Git Signs
            sign = {
                name = { "GitSigns" },
                maxwidth = 1,
                colwidth = 1,
                auto = false,
                fillchar = "%#IndentBlankLineChar#│",
                --fillchar = '▎',
            },
            click = "v:lua.ScSa",
        },
        -- {
        --     text = { " " }, -- Dummy space separator to make the UI look better
        -- },
        {
            -- All Other Signs
            sign = {
                name = { ".*" },
                fillchar = "",
                auto = false,
            },
            click = "v:lua.ScSa",
        }
    },
}

--

require("statuscol").setup(cfg)

local gitsincsCfg = {
    signs = {
        add    = { hl = 'GitSignsAdd', text = '┃ ', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
        change = { hl = 'GitSignsChange', text = '┃ ', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
        delete = { hl = 'GitSignsDelete', text = '┃ ', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
    },
}

require('gitsigns').setup(gitsincsCfg)

require("barbecue").setup()

local barbarCfg = {
    icons = {
        buffer_number = true,
    },
    exclude_ft = { 'qf' },
}

require('barbar').setup(barbarCfg)

require('telescope').load_extension('vim_bookmarks')

-- Setup menu for easier navigation
vim.keymap.set({ "v", "n" }, "<F22>", "<cmd>:popup Lsp<CR>")

vim.cmd [[:amenu 500.400 PopUp.Lsp <cmd>:popup Lsp<CR> ]] -- Always the top menu
vim.cmd [[:amenu 500.401 PopUp.Back <cmd>:execute "normal <C-o>"<CR> ]]
vim.cmd [[:amenu 10.100 Lsp.Definition <cmd>:lua = vim.lsp.buf.definition()<CR>]]
vim.cmd [[:amenu 10.110 Lsp.Peek\ Definition <cmd>:lua = vim.lsp.buf.hover()<CR>]]
vim.cmd [[:amenu 10.120 Lsp.Type\ Definition <cmd>:lua vim.lsp.buf.type_definition()<CR>]]
vim.cmd [[:amenu 10.130 Lsp.Implementations <cmd>:lua vim.lsp.buf.implementation<CR>]]
vim.cmd [[:amenu 10.140 Lsp.References <cmd>:lua vim.lsp.buf.references()<CR>]]
-- vim.cmd [[:amenu 10.150 Lsp.-sep- *]]
vim.cmd [[:amenu 10.160 Lsp.Rename <cmd>:lua = vim.lsp.buf.rename()<CR>]]
vim.cmd [[:amenu 10.170 Lsp.Code\ Actions <cmd>:lua = vim.lsp.buf.code_action()<CR>]]
