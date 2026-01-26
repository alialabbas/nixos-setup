vim.api.nvim_create_user_command("Test", function(opts)
    require("async.commands").test(opts.args)
end, { nargs = "*", complete = "file" })

vim.api.nvim_create_user_command("Make", function(opts)
    require("async.commands").make(opts.args)
end, { nargs = "*", complete = "file" })

vim.api.nvim_create_user_command("Grep", function(opts)
    require("async.commands").grep(opts.args)
end, { nargs = "*", complete = "file" })

vim.api.nvim_create_user_command("Find", function(opts)
    require("async.commands").find(opts.args)
end, { nargs = "*", complete = "file" })

vim.api.nvim_create_user_command("FuzzySearch", function(opts)
  require("async.commands").fuzzy_search(opts.args)
end, { nargs = "*" })

local function task_complete(ArgLead, CmdLine, CursorPos)
    local parts = vim.split(CmdLine:sub(1, CursorPos), "%s+")
    local n = #parts

    -- If we are at the first argument level (subcommand)
    if n == 2 then
        local subs = { "run", "list", "stop", "stopall" }
        return vim.tbl_filter(function(s)
            return s:match("^" .. ArgLead)
        end, subs)
    end

    -- Contextual completion
    local subcommand = parts[2]
    if subcommand == "run" then
        return vim.fn.getcompletion(ArgLead, "file")
    elseif subcommand == "stop" and n == 3 then
        local async = require("async")
        local tasks = async.list()
        local pids = {}
        for _, t in ipairs(tasks) do
            table.insert(pids, tostring(t.pid))
        end
        return vim.tbl_filter(function(s)
            return s:match("^" .. ArgLead)
        end, pids)
    end

    return {}
end

vim.api.nvim_create_user_command("Task", function(opts)
    local fargs = opts.fargs
    if #fargs == 0 then
        print("Usage: Task <run|list|stop|stopall> [args]")
        return
    end

    local subcommand = fargs[1]

    if subcommand == "run" then
        local cmd_args = opts.args:match("^run%s+(.*)$")
        if not cmd_args or cmd_args == "" then
            print("Usage: Task run <command>")
            return
        end
        require("async.commands").task(cmd_args)
    elseif subcommand == "list" then
        require("async.commands").list_tasks()
    elseif subcommand == "stop" then
        if not fargs[2] then
            print("Usage: Task stop <pid>")
            return
        end
        require("async.commands").stop_task(fargs[2])
    elseif subcommand == "stopall" then
        require("async.commands").stop_all()
    else
        print("Unknown subcommand: " .. subcommand)
    end
end, { nargs = "+", complete = task_complete })
