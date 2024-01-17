vim.loader.enable()
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions,globals"
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
vim.o.showmatch = true
vim.o.showmode = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.wop = "pum"

------- Window Options
vim.wo.signcolumn = "yes"
vim.wo.number = true
vim.wo.relativenumber = true

------- Options
vim.opt.tabstop = 8
vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 4
vim.opt.autoindent = true

vim.cmd.colorscheme "onehalfdark"
-- From 0.10-dev+ nvim has a default colorscheme with different groups
-- This overrides some of the new links to the old one
vim.api.nvim_set_hl(0, "NormalFloat", { link = 'Pmenu' })
vim.api.nvim_set_hl(0, "FloatBorder", { link = 'WinSeparator' })
vim.api.nvim_set_hl(0, "WinSeparator", { link = 'VertSplit' })
-- TODO: Is this another neovim color scheme changes
vim.api.nvim_set_hl(0, "@lsp.type.variable", { link = "Identifier" })
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

-- TODO: not sure why this make yamlls not loading to helm filetype but it works
-- TODO: move this to a file specific behavior
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = { '*/templates/*.yaml', '*/templates/*.tpl', '*.gotempl', 'helmfile*.yaml' },
    callback = function()
        vim.opt_local.filetype = 'helm'
        vim.opt_local.shiftwidth = 2
    end
})

vim.api.nvim_create_autocmd({ 'FileType', }, {
    pattern = "helm",
    command = [[ setlocal commentstring={{/*\ %s\ */}} ]]
})

-- TODO: ansible-vim is stupid, they look for playbook.yaml, not good enforcement on the file types based on paths
-- Can both my settings and the plugin exist together or it might just be the same as vim-help
-- TODO: with neovim the original plugin detecting the file doesn't work nicely with lspconfig somehow,
-- All of these add the same as the upstream plugin + extend what is in there already
-- TODO: languag-server has semantic highligting which makes the plugin useless for anything other than a default back when it is not running
-- TODO: syntax from the plugin is failing to load because I have TS enabled for the whole thing and nothing is overriding it or providing it with tokens
-- TODO: languageserver can take any file, should probably add yaml.ansible and yaml to it
-- TODO: add the rest of the patterns here
-- TODO: Vadlidate if we can remove the plugin and keep basic jinja2 highligting with basic vim ft
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = {
        '*/playbooks/*.yml',
        '*/playbooks/*.yaml',
        '*/tasks/*.yml',
        '*/tasks/*.yaml',
        '*/roles/*.yml',
        '*/roles/*.yaml',
        '*/handlers/*.yml',
        '*/handlers/*.yaml',
        '*/group_vars/*',
        '*/host_vars/*',
        'site.yml',
        'site.yaml',
        'main.yml',
        'main.yaml',
        'playbook.yml',
        'playbook.yaml',
    },
    callback = function()
        vim.opt_local.filetype = 'yaml.ansible'
        vim.opt_local.shiftwidth = 2
    end
})

------ GENERIC KEYMAPS
vim.api.nvim_set_keymap("n", "<C-C>", ":tabclose<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-[>", ":tabprevious<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-]>", ":tabnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("c", "w!!", "%!sudo tee > /dev/null %", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>/", ":nohlsearch<CR>", { noremap = true, silent = true })
vim.api.nvim_del_keymap("n", "<ESC>")
vim.api.nvim_set_keymap("n", "<leader>z", ":tab split<CR>", { noremap = true, silent = true })

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
}

require 'treesitter-context'.setup {
    enable = false,
}

------- Fold
vim.o.foldcolumn = '1' -- '0' is not bad
vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:,diff:/]]

------ TELESCOPE
local icons = require("nvim-nonicons")
local fb_actions = require "telescope._extensions.file_browser.actions"
require("telescope").setup({
    extensions = {
        file_browser = {
            path = vim.loop.cwd(),
            cwd = vim.loop.cwd(),
            cwd_to_path = false,
            grouped = false,
            files = true,
            add_dirs = true,
            depth = 1,
            auto_depth = false,
            select_buffer = false,
            hidden = { file_browser = false, folder_browser = false },
            respect_gitignore = vim.fn.executable "fd" == 1,
            no_ignore = false,
            follow_symlinks = false,
            browse_files = require("telescope._extensions.file_browser.finders").browse_files,
            browse_folders = require("telescope._extensions.file_browser.finders").browse_folders,
            hide_parent_dir = false,
            collapse_dirs = false,
            prompt_path = false,
            quiet = false,
            dir_icon = "",
            dir_icon_hl = "Default",
            display_stat = { date = true, size = true, mode = true },
            hijack_netrw = true,
            use_fd = true,
            git_status = true,
            mappings = {
                ["i"] = {
                    ["<A-c>"] = fb_actions.create,
                    ["<S-CR>"] = fb_actions.create_from_prompt,
                    ["<A-r>"] = fb_actions.rename,
                    ["<A-m>"] = fb_actions.move,
                    ["<A-y>"] = fb_actions.copy,
                    ["<A-d>"] = fb_actions.remove,
                    ["<C-o>"] = fb_actions.open,
                    ["<C-g>"] = fb_actions.goto_parent_dir,
                    ["<C-e>"] = fb_actions.goto_home_dir,
                    ["<C-w>"] = fb_actions.goto_cwd,
                    ["<C-t>"] = fb_actions.change_cwd,
                    ["<C-f>"] = fb_actions.toggle_browser,
                    ["<C-h>"] = fb_actions.toggle_hidden,
                    ["<C-s>"] = fb_actions.toggle_all,
                    ["<bs>"] = fb_actions.backspace,
                },
                ["n"] = {
                    ["c"] = fb_actions.create,
                    ["r"] = fb_actions.rename,
                    ["m"] = fb_actions.move,
                    ["y"] = fb_actions.copy,
                    ["d"] = fb_actions.remove,
                    ["o"] = fb_actions.open,
                    ["g"] = fb_actions.goto_parent_dir,
                    ["e"] = fb_actions.goto_home_dir,
                    ["w"] = fb_actions.goto_cwd,
                    ["t"] = fb_actions.change_cwd,
                    ["f"] = fb_actions.toggle_browser,
                    ["h"] = fb_actions.toggle_hidden,
                    ["s"] = fb_actions.toggle_all,
                },
            },
        },
    },
    defaults = {
        prompt_prefix = "  " .. icons.get("telescope") .. "  ",
        selection_caret = " ❯ ",
        entry_prefix = "   ",
    },
})
require('telescope').load_extension('ui-select')
require("telescope").load_extension("yaml_schema")
require('telescope').load_extension('repo')
require('telescope').load_extension('file_browser')

local events = {
    'CursorHold',
    'BufWinEnter',
    'BufWinLeave',
    'WinNew',
    'WinClosed',
    'TabNew',
}

vim.api.nvim_create_autocmd(events, {
    group = vim.api.nvim_create_augroup('PossessionAutosave', { clear = true }),
    callback = function()
        local session = require('possession.session')
        if session.session_name then
            session.autosave()
        end
    end
})
require 'possession'.setup({
    autosave = {
        current = true,           -- or fun(name): boolean
        tmp = true,               -- or fun(): boolean
        tmp_name = 'tmp-session', -- or fun(): string
        on_load = true,
        on_quit = true,
    },
})
require('telescope').load_extension('possession')

vim.g.rooter_cd_cmd = 'tcd'
vim.g.rooter_patterns = {
    '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile',
    'package.json', 'go.mod', '*.csproj', '*.sln', 'Chart.yaml' }

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

vim.api.nvim_set_keymap("n", "<F21>" --[[ Shift + F9]],
    [[ <Esc><Cmd>lua vim.ui.input({ prompt = "Breakpoint Condition: ",}, function(input) require("dap").set_breakpoint(input)end)<CR> ]],
    defaultKeymapOptions)

local dap, dapui = require("dap"), require("dapui")
vim.api.nvim_set_hl(0, "DapBreakpoint", { ctermbg = 0, fg = "#993939" })
vim.api.nvim_set_hl(0, "DapLogPoint", { ctermbg = 0, fg = "#61afef" })
vim.api.nvim_set_hl(0, "DapStopped", { ctermbg = 0, fg = "#98c379" })
vim.fn.sign_define("DapBreakpoint", { text = "◕", texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "⚉", texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DapLogPoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "", texthl = "DapStopped", linehl = "", numhl = "" })

dapui.setup()
require("nvim-dap-virtual-text").setup()

local currWorkspace = vim.fn.getcwd()

local debug_win = nil
local function open_in_tab()
    if debug_win and vim.api.nvim_win_is_valid(debug_win) then
        vim.api.nvim_set_current_win(debug_win)
        return
    end

    vim.cmd("tabedit %")
    debug_win = vim.fn.win_getid()
    require("dapui").open()
    local sidebar_sessions = require 'dap.ui.widgets'.sidebar(require 'dap.ui.widgets'.sessions)
    sidebar_sessions.open()
    vim.cmd("TabRename Debug")
end

-- Because go is special and we need to revert back to the correct workspace before and while debugging as well
dap.listeners.before.event_terminated["dapui_config"] = function()
    vim.api.nvim_set_current_dir(currWorkspace)
end
dap.listeners.before.event_exited["dapui_config"] = function()
    vim.api.nvim_set_current_dir(currWorkspace)
end



dap.listeners.after.event_initialized["dapui_config"] = function()
    vim.api.nvim_set_current_dir(currWorkspace)
    open_in_tab()
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
        -- local result = vim.fn.system({ 'find', path, '-name', 'go.mod' }) -- this could be replaced vim.fn.glob
        local result = vim.fn.glob("./**/go.mod")
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
    print(vim.inspect(result))

    return vim.lsp.handlers['textDocument/definition'](err, result, ctx, config)
end

-- TODO: this need to change telescope handler as well
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

local servers = { "gopls", "helm_ls", "jsonnet_ls", "pyright", "fsautocomplete" }
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

require 'ufo'.setup()

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

local open_terminal = function()
    require('toggleterm')
    local tabno = vim.api.nvim_get_current_tabpage()
    local command = ":" .. tabno .. "ToggleTerm<CR>"
end


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
            },
        },
        lualine_y = { 'progress',
            {
                'searchcount',
                on_click = function(_nb_of_clicks, _button, _modifiers)
                    require "telescope.builtin".current_buffer_fuzzy_find
                    {
                        default_text = vim.fn.getreg("/"),
                        initial_mode = "normal",
                    }
                end
            }
        },
        lualine_z = { 'location' },
    },
    options = {
        disabled_filetypes = {
            statusline = {
                "SidebarNvim",
            }
        },
    },
    extensions = { 'nvim-dap-ui', 'toggleterm', 'fugitive', 'quickfix', },
})
-- Remove Search Results from cmdline
vim.o.shortmess = vim.o.shortmess .. "S"

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = { '*.csproj' },
    callback = function()
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

        ---Register your source to nvim-cmp.
        require('cmp').register_source('csproj', source)
    end
})


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
        {
            -- Diagnostics
            sign = {
                namespace = { "diagnostic" },
                maxwidth = 1,
                colwidth = 1,
                auto = false,
                fillchars = ""
            },
            click = "v:lua.ScSa",
        },
        {
            -- Dap
            sign = {
                name = { "DapBreakpoint", "DapStopped", },
                maxwidth = 1,
                colwidth = 1,
                auto = false,
            },
            click = "v:lua.ScSa",
        },
        {
            sign = {
                name = { "Bookmark", "BookmarkAnnotation" },
                maxwidth = 1,
                colwidth = 1,
                auto = false,
            },
            click = "v:lua.BookmarkAction",
        },
        {
            sign = {
                namespace = { "gitsign" },
                maxwidth = 1,
                colwidth = 1,
                auto = false,
            },
            click = "v:lua.ScSa",
        },
        {
            -- Line Numbers
            text = { builtin.lnumfunc },
            click = "v:lua.ScLa",
        },
        {
            text = { " " }, -- Dummy space separator to make the UI look better
        },
    },
}

require("statuscol").setup(cfg)
require('ibl').setup({
    scope = { show_start = false, enabled = false, },
})
local hooks = require("ibl.hooks")
hooks.register(hooks.type.ACTIVE, function(bufnr)
    return not vim.tbl_contains(
        { "dashboard", },
        vim.api.nvim_get_option_value("filetype", { buf = bufnr })
    )
end)

local gitsincsCfg = {
    signs = {
        add    = { hl = 'GitSignsAdd', text = '+', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
        change = { hl = 'GitSignsChange', text = '~', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
        delete = { hl = 'GitSignsDelete', text = '-', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
    },
}

require('gitsigns').setup(gitsincsCfg)

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
        vim.keymap.set("n", "<leader>f", require("dropbar.api").pick, { noremap = true, silent = true })
    end
})

-- TODO: should be set using Colorscheme AUTOCMD
vim.api.nvim_set_hl(0, "TabLineIn", { bg = '#abb2bf', fg = '#282c34' })
vim.api.nvim_set_hl(0, "TabLineHead", { fg = '#282c34', bg = '#61afef' })
vim.api.nvim_set_hl(0, "TabFill", { bg = "#282c34" })
vim.api.nvim_set_hl(0, "TabLineSel", { fg = '#282c34', bg = '#61afef' })

require("tabby").setup()
-- TODO: There is a corner case here when we switch quickly between tabs before the rename happens
-- We could avoid bad renaming by keeping a local table with tabid and their generated names
-- This make it so that if we have a page named already, unless the current path is different
-- and not in the same local path, then we attempt to rename, also need to handle `.` condition
-- I think it is just that the stupid code doesn't handle mutliple tabs correctly and it doesn't cancel any switching on views
-- I could just make this take the id of the buffer
-- Then from the id generate a name
-- Then for multiple debug views, I could just store that view in a table or just create a custom tab gui
-- Or I could just rely on a single debug ui for now, i.e I am only debugging one thing and one thing only.
-- Actually, can dap support this anyway... I didn't even try it lol
-- TODO: this is fallback and then I could just create a wrapper around TabEnter events and BufEnter events
-- The buffer aka the path of the project is what will control this and just modify this as we go along
-- FindRootDirectory() ---> Rooter can help script this since we want whatever it returns as the path
-- DirChanged ---> cmd for this so that I am able to just set it whenever the cd changes once and that's it
vim.api.nvim_create_autocmd(
    { "DirChanged" },
    {
        callback = function(args)
            local tab_name = vim.fn.fnamemodify(args.file, ":t")
            require 'tabby'.tab_rename(tab_name)
        end,
    })

local function tab_modified(tab)
    local wins = require("tabby.module.api").get_tab_wins(tab)
    for _, x in pairs(wins) do
        if vim.bo[vim.api.nvim_win_get_buf(x)].modified then
            return ""
        end
    end
    return ""
end

local theme = {
    fill = 'TabFill',
    head = 'TabLineHead',
    current_tab = 'TabLineSel',
    inactive_tab = 'TabLineIn',
    tab = 'TabLine',
    win = 'TabLineHead',
    tail = 'TabLineHead',
}
require('tabby.tabline').set(function(line)
    return {
        {
            { '  ', hl = theme.head },
            line.sep('', theme.head, theme.fill),
        },
        line.tabs().foreach(function(tab)
            local hl = tab.is_current() and theme.current_tab or theme.inactive_tab
            return {
                line.sep('', hl, theme.fill),
                tab.number(),
                "",
                tab.name(),
                "",
                tab_modified(tab.id),
                line.sep('', hl, theme.fill),
                hl = hl,
                margin = ' ',
            }
        end),
        line.spacer(),
        {
            line.sep('', theme.tail, theme.fill),
            { '  ', hl = theme.tail },
        },
        hl = theme.fill,
    }
end)

require('telescope').load_extension('vim_bookmarks')


vim.g.netrw_liststyle = 3
vim.g.netrw_banner = 0

require("gitlinker").setup({
    callbacks = {
        ["gitlab"] = require "gitlinker.hosts".get_gitlab_type_url
    }
})

local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Set header
dashboard.section.header.val = {
    "                                                     ",
    "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
    "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
    "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
    "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
    "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
    "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
    "                                                     ",
}

local version = vim.version()
dashboard.section.footer.val = string.format(
    'v%s.%s.%s%s',
    version.major,
    version.minor,
    version.patch,
    version.api_prerelease and ' (Nightly)' or ''
)


-- Set menu
dashboard.section.buttons.val = {
    dashboard.button("e", "  > New file", ":ene <BAR> startinsert <CR>"),
    dashboard.button("f", "  > Find file", ":Telescope find_files<CR>"),
    dashboard.button("p", "  > Projects", ":Telescope repo list<CR>"),
    dashboard.button("s", "  > Sessions", ":Telescope possession list<CR>"),
    dashboard.button("r", "  > Recent", ":Telescope oldfiles<CR>"),
    dashboard.button("w", "󰛔  > Fuzzy Search", ":Telescope live_grep<CR>"),
    dashboard.button("m", "  > Open Bookmarks", ":Telescope vim_bookmarks<CR>"),
    dashboard.button("q", "󰅚  > Quit NVIM", ":qa<CR>"),
}

dashboard.section.buttons.opts = { position = "center", }

-- Send config to alpha
alpha.setup(dashboard.opts)

-- Disable folding on alpha buffer
vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
]])

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
