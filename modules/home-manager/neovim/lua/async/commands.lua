local async = require("async")
local M = {}

function M._find_text_func(info)
    local items = vim.fn.getqflist({ id = info.id, items = 1 }).items
    local res = {}
    for i = info.start_idx, info.end_idx do
        local item = items[i]
        if item.lnum == 0 and item.col == 0 and item.text == "" then
            table.insert(res, vim.fn.bufname(item.bufnr))
        else
            local fname = vim.fn.bufname(item.bufnr)
            local line = item.lnum > 0 and ("|" .. item.lnum .. "|") or ""
            table.insert(res, fname .. line .. " " .. item.text)
        end
    end
    return res
end

local function get_cmd(prg, args)
    if not args or args == "" then return prg:gsub("%$%*", "") end
    if prg:find("%$%*") then return prg:gsub("%$%*", args) end
    return prg .. " " .. args
end

---
--Generates a safe buffer name for a task type and project root
---
---@param type string
---@return string
local function get_task_buf_name(type)
    local project = vim.fn.fnamemodify(vim.uv.cwd(), ":t")
    return string.format("//task/%s/%s", type, project)
end

---
--Get or create a buffer by name
---
---@param name string
---@return number bufnr
local function get_or_create_buf(name)
    local bufnr = vim.fn.bufnr("^" .. name .. "$")
    if bufnr ~= -1 then
        return bufnr
    end
    local b = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(b, name)
    return b
end

function M._run_nav_task(type, cmd_str, efm)
    local winid = vim.api.nvim_get_current_win()
    local buf_name = get_task_buf_name(type)
    local bufnr = get_or_create_buf(buf_name)
    local cmd = vim.fn.expand(cmd_str)

    async.run(cmd, {
        sinks = {
            async.sinks.buffer.new({
                bufnr = bufnr,
                efm = efm,
                winid = winid,
                auto_open = true,
                clear = true
            }),
            async.sinks.fidget.new(),
        }
    })
end

function M.test(args)
    local prg = vim.b.testprg
    if not prg or prg == "" then
        return vim.notify("No b:testprg set for this buffer", vim.log.levels.WARN)
    end

    local efm = (vim.b.testefm and vim.b.testefm ~= "") and vim.b.testefm or vim.bo.errorformat
    local cmd = get_cmd(prg, args)

    local winid = vim.api.nvim_get_current_win()
    local project = vim.fn.fnamemodify(vim.uv.cwd(), ":t")
    local expanded_cmd = vim.fn.expand(cmd)

    async.run(expanded_cmd, {
        sinks = {
            -- Sink 1: Compact/Filtered QF View
            async.sinks.buffer.new({
                bufnr = get_or_create_buf(string.format("//task/test/qf/%s", project)),
                efm = "%f:%l:%c: %m",
                winid = winid,
                auto_open = true,
                clear = true,
                processor = require("async.processors").create_qf_processor,
                processor_opts = {
                    efm = efm,
                    qf_only = true,
                }
            }),
            -- Sink 2: Raw/Full ANSI Log
            async.sinks.buffer.new({
                bufnr = get_or_create_buf(string.format("//task/test/raw/%s", project)),
                winid = winid,
                auto_open = false, -- Keep hidden by default
                clear = true,
                processor = require("async.ansi").create_processor,
            }),
            async.sinks.fidget.new(),
        }
    })
end

function M.make(args)
    local prg = vim.bo.makeprg ~= "" and vim.bo.makeprg or vim.go.makeprg
    local efm = vim.bo.errorformat ~= "" and vim.bo.errorformat or vim.go.errorformat
    local cmd = get_cmd(prg, args)
    M._run_nav_task("make", cmd, efm)
end

function M.grep(args)
    local prg = vim.bo.grepprg ~= "" and vim.bo.grepprg or vim.go.grepprg
    local efm = vim.bo.grepformat ~= "" and vim.bo.grepformat or vim.go.grepformat

    -- If using rg, ensure color is always on for the buffer sink
    if prg:match("^rg%s") or prg == "rg" then
        if not prg:find("%-%-color") then
            prg = prg .. " --color=always"
        end
        -- Ensure vimgrep format for reliable navigation if not already specified
        if not prg:find("%-%-vimgrep") and not prg:find("%-%-column") then
            prg = prg .. " --vimgrep"
        end
    end

    local cmd = get_cmd(prg, args)
    M._run_nav_task("grep", cmd, efm)
end

function M.find(args)
    local prg = vim.fn.executable("fd") == 1 and "fd" or "find ."

    -- Enable color for fd
    if prg == "fd" then
        prg = prg .. " --color=always"
    end

    local cmd = prg .. " " .. args
    M._run_nav_task("find", cmd, "%f")
end

function M.task(args)
    async.run(args, { sinks = { async.sinks.buffer.new(), async.sinks.fidget.new() } })
end

function M.list_tasks()
    local tasks = async.list()
    if #tasks == 0 then return vim.notify("No running tasks.", vim.log.levels.INFO) end
    local lines = { "Running Tasks:" }
    for _, t in ipairs(tasks) do
        table.insert(lines, string.format("[%d]: %s", t.pid, table.concat(t.cmd, " ")))
    end
    print(table.concat(lines, "\n"))
end

function M.stop_task(pid_str)
    local pid = tonumber(pid_str)
    if not pid then return vim.notify("Invalid PID: " .. tostring(pid_str), vim.log.levels.ERROR) end
    async.stop(pid)
    vim.notify("Sent SIGTERM to task " .. pid, vim.log.levels.INFO)
end

function M.stop_all() async.stop_all() end

local fuzzy_pid = nil

-- Core search engine for FuzzySearch
function M._run_fuzzy_search(query, results_buf, results_win_id)
    query = query:match("^%s*(.-)%s*$")
    if not query or query == "" then
        if fuzzy_pid then async.stop(fuzzy_pid) end
        vim.bo[results_buf].modifiable = true
        vim.api.nvim_buf_set_lines(results_buf, 0, -1, false, {})
        vim.bo[results_buf].modifiable = false
        vim.bo[results_buf].modified = false
        return
    end

    if fuzzy_pid then async.stop(fuzzy_pid) end

    local ok, extra_args = pcall(vim.api.nvim_buf_get_var, results_buf, "fuzzy_args")
    if not ok then extra_args = "" end

    local cmd = string.format("rg --column --line-number --no-heading --smart-case %s . 2>/dev/null | fzf --filter=%s",
        extra_args, vim.fn.shellescape(query))

    fuzzy_pid = async.run(cmd, {
        sinks = {
            async.sinks.buffer.new({
                bufnr = results_buf,
                winid = results_win_id,
                auto_open = false,
                clear = true,
                efm = "%f:%l:%c:%m",
                processor = require("async.processors").create_processor,
                processor_opts = {
                    pattern = "^(.-):(%d+):(%d+):(.*)$"
                }
            }),
            async.sinks.fidget.new()
        }
    })
end

function M.fuzzy_search(args)
    local results_win = vim.api.nvim_get_current_win()
    local project_name = vim.fn.fnamemodify(vim.uv.cwd(), ":t")
    local results_buf = get_or_create_buf("//task/fuzzy_search/" .. project_name)

    vim.cmd("botright sbuffer " .. results_buf)
    vim.api.nvim_win_set_height(0, 15)
    vim.wo.winfixheight = true

    vim.b[results_buf].is_fuzzy_search = true
    vim.b[results_buf].fuzzy_win = results_win
    vim.b[results_buf].fuzzy_args = args

    vim.api.nvim_feedkeys("/", "n", false)
end

-- Hook for command-line commit (Enter)
vim.api.nvim_create_autocmd("CmdlineLeave", {
    callback = function()
        local event = vim.v.event
        if event.cmdtype == "/" and not event.abort and vim.b.is_fuzzy_search then
            local query = vim.fn.getcmdline()
            local buf = vim.api.nvim_get_current_buf()
            local ok, win = pcall(vim.api.nvim_buf_get_var, buf, "fuzzy_win")
            if ok then
                M._run_fuzzy_search(query, buf, win)
            end
        end
    end
})

return M
