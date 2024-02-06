local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<F5>", ":DapContinue<CR>", opts)
vim.api.nvim_set_keymap("n", "<F9>", ":DapToggleBreakpoint<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader><F9>", [[ <Esc><Cmd>lua require('dap').clear_breakpoints()<CR>]],
    { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F10>", ":DapStepOver<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader><F11>", ":DapStepOut<CR>", opts)
vim.api.nvim_set_keymap("n", "<F11>", ":DapStepInto<CR>", opts)

vim.api.nvim_set_keymap("n", "<F21>" --[[ Shift + F9]],
    [[ <Esc><Cmd>lua vim.ui.input({ prompt = "Breakpoint Condition: ",}, function(input) require("dap").set_breakpoint(input)end)<CR> ]],
    opts)

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
require("nvim-dap-virtual-text").setup({ enabled = false })

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

dap.listeners.after.event_initialized["dapui_config"] = function()
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
