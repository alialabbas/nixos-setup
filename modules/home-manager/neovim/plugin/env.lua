local function env_complete(ArgLead, CmdLine, CursorPos)
    local parts = vim.split(CmdLine:sub(1, CursorPos), "%s+")
    local n = #parts

    if n == 2 then
        local subs = { "set" }
        return vim.tbl_filter(function(s)
            return s:match("^" .. ArgLead)
        end, subs)
    elseif n == 3 and parts[2] == "set" then
        -- Complete existing environment variables if the user is typing one
        return vim.tbl_filter(function(s)
            return s:match("^" .. ArgLead)
        end, vim.tbl_keys(vim.fn.environ()))
    end
    return {}
end

vim.api.nvim_create_user_command("Env", function(opts)
    local fargs = opts.fargs
    if #fargs < 1 then
        vim.notify("Usage: Env <subcommand> [args...]", vim.log.levels.ERROR)
        return
    end

    local sub = fargs[1]
    if sub == "set" then
        if #fargs < 3 then
            vim.notify("Usage: Env set <NAME> <VALUE>", vim.log.levels.ERROR)
            return
        end
        -- Combine remaining args as the value in case it contains spaces
        local name = fargs[2]
        local value = table.concat(fargs, " ", 3)
        require("env").set(name, value)
    else
        vim.notify("Unknown Env subcommand: " .. sub, vim.log.levels.ERROR)
    end
end, {
    nargs = "+",
    complete = env_complete,
})
