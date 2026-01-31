local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<F5>", ":DapContinue<CR>", opts)
vim.api.nvim_set_keymap("n", "<F9>", ":DapToggleBreakpoint<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader><F9>", [[ <Esc><Cmd>lua require('dap').clear_breakpoints()<CR>]],
    { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F10>", ":DapStepOver<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader><F11>", ":DapStepOut<CR>", opts)
vim.api.nvim_set_keymap("n", "<F11>", ":DapStepInto<CR>", opts)

vim.api.nvim_set_keymap("n", "<F21>" --[[ Shift + F9]],
    [[ <Esc><Cmd>lua vim.ui.input({ prompt = "Breakpoint Condition: ",}, function(input) require("dap").set_breakpoint(input)end)<CR> ]],
    opts)

vim.api.nvim_set_keymap("n", "<F33>" --[[ Ctrl + F9 ]],
    [[ <Esc><Cmd>lua vim.ui.input({ prompt = "Log point message: ",}, function(input) if input then require("dap").set_breakpoint(nil, nil, input) end end)<CR> ]],
    opts)

local dap = require("dap")
vim.api.nvim_set_hl(0, "DapBreakpoint", { ctermbg = 0, fg = "#993939" })
vim.api.nvim_set_hl(0, "DapLogPoint", { ctermbg = 0, fg = "#61afef" })
vim.api.nvim_set_hl(0, "DapStopped", { ctermbg = 0, fg = "#98c379" })
vim.fn.sign_define("DapBreakpoint", { text = "◕", texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "⚉", texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DapLogPoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "", texthl = "DapStopped", linehl = "", numhl = "" })

require("dap-view").setup({})

dap.listeners.after.event_initialized["dapui_config"] = function()
    vim.cmd(":DapViewOpen")
end

local FS = {}

--- Open a file and return its content
---@param path string file to load
---@return string content
FS.read_file = function(path)
    local fd = assert(vim.uv.fs_open(path, "r", 438))
    local stat = assert(vim.uv.fs_fstat(fd))
    local data = assert(vim.uv.fs_read(fd, stat.size, 0))
    assert(vim.uv.fs_close(fd))
    return data
end

--- walk up from the start dir and find a file matching the pattern
---@param start string
---@param pattern string supports glob pattern
---@return string[]
FS.find_root = function(start, pattern)
    if start == "/" then
        return {}
    end

    local result = vim.fn.glob(start .. "/" .. pattern, true, true)
    if not vim.tbl_isempty(result) then
        return result
    end

    return FS.find_root(vim.fn.fnamemodify(start, ":h"), pattern)
end

local Treesitter = {}

--- Generic parse query method that would either process a query on a buffer or string content
---@param query string TS query
---@param file integer|string buf id or file content
---@param lang string language to use in the query
---@param to_capture string[] list of strings representing capture groups in the passed query.
---@return table<string, any>[] list of tables, each table contains a full capture group based on the specified spec in to_capture
Treesitter.parse_query = function(query, file, lang, to_capture)
    local is_string = type(file) == "string"
    local parser_func = is_string and vim.treesitter.get_string_parser or vim.treesitter.get_parser

    local language_tree = parser_func(file, lang)
    local root = language_tree:parse()[1]:root()

    local output = {}
    local query_result = vim.treesitter.query.parse(lang, query)
    for _, captures, _ in query_result:iter_matches(root, file) do
        local result = {}
        for id, node in pairs(captures) do
            local capture = query_result.captures[id]
            if vim.tbl_contains(to_capture, capture) then
                result[capture] = {}
                result[capture].value = vim.treesitter.get_node_text(node, file)

                result[capture].row_start,
                result[capture].col_start,
                result[capture].row_end,
                result[capture].col_end =
                    vim.treesitter.get_node_range(node)
            end
        end
        table.insert(output, result)
    end

    if is_string then
        local bufnr = language_tree:source()
        if type(bufnr) == "number" then
            vim.api.nvim_buf_delete(bufnr, { force = true })
        end
    end

    return output
end


Dotnet = {}
Dotnet.ts = {
    lang = {
        CS = "c_sharp",
        CSPROJ = "xml"
    }
}

Dotnet.ts.queries = {
    tests = [[
        (file_scoped_namespace_declaration
          (qualified_name)@namespace
          (class_declaration
            (identifier)@class
            (declaration_list
                (method_declaration (attribute_list(attribute
                        name: (identifier))@attr (#match? @attr "Fact"))
                    name: (identifier)@method)
            )
          )
        )
    ]],
    frameworks = [[
        (element
            (STag
              (Name
            )@name)@tag
            (#match? @tag "TargetFramework")
            (content)@frameworks
        )
    ]],
    runnable_projects = [[
        ;; web sdk projects
        (element
          (STag (Name)@name (#match? @name "Project")
                (Attribute (Name)@attrName (#match? @attrName "Sdk")
                   (AttValue)@attrVal (#match? @attrVal "Microsoft.NET.Sdk.Web")
                )
            )@tag
        )

        ;; cli projects
        (element
          (content
            (element
              (STag)@outputType(#match? @outputType "OutputType")
              (content(CharData)@type)
              )
            )
          )
    ]],
    test_projects = [[
        (element
          (content
            (element
              (content
                (element
                  (EmptyElemTag
                    (Attribute
                      (Name)@name (#match? @name "Include")
                      (AttValue)@value (#match? @value "Microsoft.NET.Test.Sdk")
                      )
                    )
                  )
                )
              )
            )
          )
    ]]
}

---Get all tests in a buffer
---@param bufnr number
---@return string[]
Dotnet.get_tests = function(bufnr)
    local result = Treesitter.parse_query(
        Dotnet.ts.queries.tests,
        bufnr,
        Dotnet.ts.lang.CS,
        { "namespace", "class", "method" })

    local tests = {}
    for _, capture in ipairs(result) do
        local test = capture.namespace.value .. "." .. capture.class.value .. "." .. capture.method.value
        table.insert(tests, test)
    end
    return tests
end

---Build dotnet project in a path
---@param project string directory path to csproj or csproj file
---@return boolean whether the build succeeded or failed
Dotnet.build = function(project)
    local cmd = "dotnet build -c Debug " .. project .. " > /dev/null"
    vim.notify("Cmd to execute: " .. cmd, vim.log.levels.DEBUG)
    local f = os.execute(cmd)
    if f == 0 then
        vim.notify("Build: ✔️ ", vim.log.levels.INFO)
        return true
    else
        vim.notify("Build: ❌ (code: " .. f .. ")", vim.log.levels.ERROR)
        return false
    end
end

--- Find all the possible dll for a given project.
---@param project string the project to run
---@return string[] dll paths
Dotnet.find_dll = function(project)
    if vim.fn.fnamemodify(project, ":e") ~= "csproj" then
        return {}
    end

    local content = FS.read_file(project)
    local dll_name = vim.fn.fnamemodify(project, ":t:r") .. ".dll"

    local result = Treesitter.parse_query(
        Dotnet.ts.queries.frameworks,
        content,
        Dotnet.ts.lang.CSPROJ,
        { "frameworks" })

    local frameworks = result[1].frameworks

    local output = {}
    local root_path = vim.fn.fnamemodify(project, ":h")
    for _, framework in ipairs(vim.split(frameworks.value, ";")) do
        table.insert(output, root_path .. "/bin/Debug/" .. framework .. "/" .. dll_name)
    end
    return output
end

--- Run dotnet test and return the testhost pid
---@param project string csproj project to test
---@param test_args? table|string additional args to pass to dotnet test command
---@return integer|nil vshost pid
Dotnet.test = function(project, test_args)
    if vim.fn.fnamemodify(project, ":e") ~= "csproj" then
        return nil
    end

    -- Filter for the expected dll name, doesn't work AsemblyName is not the same as csproj
    local result = Dotnet.find_dll(project)[1]
    vim.fn.jobstart('dotnet test ' .. result .. ' ' .. (test_args or ''),
        { env = { ["VSTEST_HOST_DEBUG"] = "1" }, })
    local vstest_predicate = function(proc)
        return proc.name:find("vstest.console.dll " .. result)
    end


    local vstest = {}
    while vim.tbl_isempty(vstest) do -- This blocks the UI.... need a way to avoid this
        vstest = vim.tbl_filter(vstest_predicate, require 'dap.utils'.get_processes())
    end

    local testhost_predicate = function(proc)
        return proc.name:find(tostring(vstest[1].pid))
    end

    local host = {}

    while vim.tbl_isempty(host) do
        host = vim.tbl_filter(testhost_predicate, require 'dap.utils'.get_processes())
    end

    return host[1].pid
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

dap.adapters.netcoredbg = {
    type = "executable",
    command = "netcoredbg",
    args = { "--interpreter=vscode" }
}

dap.configurations.cs = {
    {
        type = "netcoredbg",
        name = "Run Project",
        request = "launch",
        program = function()
            return coroutine.create(function(dap_run_co)
                local projects = {}

                local process_csproj_content = function(file_path, content)
                    local query_result = Treesitter.parse_query(
                        Dotnet.ts.queries.runnable_projects,
                        content,
                        Dotnet.ts.lang.CSPROJ,
                        { "attrVal", "type" })

                    if not vim.tbl_isempty(query_result) then
                        table.insert(projects, file_path)
                    end
                end

                local on_event = function(job_id, data, event)
                    if event == "stdout" and data then
                        for _, file in ipairs(data) do
                            if file ~= "" then
                                local content = FS.read_file(file)
                                process_csproj_content(file, content)
                            end
                        end
                    end
                end

                local job_id = vim.fn.jobstart("git ls-files *.csproj", { on_stdout = on_event, stdout_buffered = true })
                vim.fn.jobwait({ job_id })

                vim.ui.select(projects, { label = '> ' }, function(choice)
                    if not Dotnet.build(choice) then return end

                    local result = Dotnet.find_dll(choice)
                    coroutine.resume(dap_run_co, result[1])
                end)
            end)
        end,
        args = function() return vim.g.get_dap_args() end
    },
    {
        type = "netcoredbg",
        name = "Run Current Project",
        request = "launch",
        program = function()
            return coroutine.create(function(dap_run_co)
                local curr_path = vim.fn.expand("%:h")
                local project_root = FS.find_root(curr_path, "*.csproj")[1]


                if not Dotnet.build(project_root) then return end
                local result = Dotnet.find_dll(project_root)
                coroutine.resume(dap_run_co, result[1])
            end)
        end,
        args = vim.g.get_dap_args
    },
    {
        type = "netcoredbg",
        name = "Attach to Process",
        request = "attach",
        processId = require 'dap.utils'.pick_process,
    },
    {
        type = "netcoredbg",
        name = "Test Project",
        request = "attach",
        processId = function()
            return coroutine.create(function(dap_run_co)
                local projects = {}

                local process_csproj_content = function(file_path, content)
                    local result = Treesitter.parse_query(
                        Dotnet.ts.queries.test_projects,
                        content,
                        Dotnet.ts.lang.CSPROJ,
                        { "value" })

                    if not vim.tbl_isempty(result) then
                        table.insert(projects, file_path)
                    end
                end

                local on_event = function(job_id, data, event)
                    if event == "stdout" and data then
                        for _, file in ipairs(data) do
                            if file ~= "" then
                                local content = FS.read_file(file)
                                process_csproj_content(file, content)
                            end
                        end
                    end
                end


                local job_id = vim.fn.jobstart("git ls-files *.csproj", { on_stdout = on_event, stdout_buffered = true })
                vim.fn.jobwait({ job_id })

                vim.ui.select(projects, { label = '> ' }, function(choice)
                    if not Dotnet.build(choice) then return end

                    coroutine.resume(dap_run_co, Dotnet.test(choice))
                end)
            end)
        end,
    },
    {
        type = "netcoredbg",
        name = "Test Current File",
        request = "attach",
        processId = function()
            return coroutine.create(function(dap_run_co)
                local curr_path = vim.fn.expand("%:p:h")
                local project_root = FS.find_root(curr_path, "*.csproj")[1]

                local content = FS.read_file(project_root)
                local query_result = Treesitter.parse_query(
                    Dotnet.ts.queries.test_projects,
                    content,
                    Dotnet.ts.lang.CSPROJ,
                    { "value" })

                if vim.tbl_isempty(query_result) then
                    vim.notify(project_root .. " is not a test project", vim.log.levels.ERROR)
                    return
                end


                if not Dotnet.build(project_root) then return end

                local tests = Dotnet.get_tests(vim.api.nvim_get_current_buf())
                local result = vim.iter(tests):fold("", function(t, v)
                    if t == "" then
                        return v
                    else
                        return t .. "|" .. v
                    end
                end)

                local test_pid = Dotnet.test(project_root, "--filter " .. result)
                coroutine.resume(dap_run_co, test_pid)
            end)
        end,
    },
    {
        type = "netcoredbg",
        name = "Test Current Project",
        request = "attach",
        processId = function()
            return coroutine.create(function(dap_run_co)
                local curr_path = vim.fn.expand("%:p:h")
                local project_root = FS.find_root(curr_path, "*.csproj")[1]

                if not Dotnet.build(project_root) then return end

                local host_pid = Dotnet.test(project_root)
                coroutine.resume(dap_run_co, host_pid)
            end)
        end,
    }
}



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
    },
    {
        type = "go",
        name = "Attach to Process",
        request = "attach",
        processId = require 'dap.utils'.pick_process,
    },
}
