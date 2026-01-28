local utils = require("async.utils")
local M = {}

local function get_project_name()
    return vim.fn.fnamemodify(vim.uv.cwd(), ":t")
end

local function get_task_buffers()
    local bufs = {}
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) then
            local name = vim.api.nvim_buf_get_name(bufnr)
            -- Match //task/ anywhere in the name (handles potential path expansion)
            if name:match("//task/") then
                table.insert(bufs, bufnr)
            end
        end
        end
        return bufs
    end
    
    function M.navigate(direction)
    
    local project = get_project_name()
    local bufs = get_task_buffers()
    
    print(string.format("[TaskNav] Project: %s, Total task bufs found: %d", project, #bufs))

    local project_bufs = {}
    -- Escape magic characters in project name for Lua pattern matching
    local escaped_project = project:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")

    for _, bufnr in ipairs(bufs) do
        local name = vim.api.nvim_buf_get_name(bufnr)
        local pattern = "//task/.+/" .. escaped_project .. "$"
        if name:match(pattern) then
            table.insert(project_bufs, bufnr)
        else
            print(string.format("[TaskNav] Skipping %s (doesn't match %s)", name, pattern))
        end
    end

    if #project_bufs == 0 then
        print("[TaskNav] ERROR: No task buffers matched current project: " .. project)
        vim.notify("No task buffers for project: " .. project, vim.log.levels.WARN)
        return
    end

    -- Sort by lastused timestamp (Most Recently Used)
    table.sort(project_bufs, function(a, b)
        local info_a = vim.fn.getbufinfo(a)[1]
        local info_b = vim.fn.getbufinfo(b)[1]
        return (info_a.lastused or 0) > (info_b.lastused or 0)
    end)

    -- The first one in the sorted list is our "Active" list
    local target_buf = project_bufs[1]
    local target_win = 0
    
    -- If the most recently used one is visible, use its window to track cursor
    local wins = vim.fn.win_findbuf(target_buf)
    if #wins > 0 then
        target_win = wins[1]
    end

    print(string.format("[TaskNav] Using buffer: %s (bufnr: %d, win: %d)", 
        vim.api.nvim_buf_get_name(target_buf), target_buf, target_win))

    local efm = vim.bo[target_buf].errorformat
    if efm == "" then efm = vim.go.errorformat end
    print("[TaskNav] Using efm: " .. efm)

    local line_count = vim.api.nvim_buf_line_count(target_buf)
    local current_line = 0
    if target_win ~= 0 then
        current_line = vim.api.nvim_win_get_cursor(target_win)[1]
    else
        current_line = vim.b[target_buf].last_nav_line or 0
    end

    print(string.format("[TaskNav] Current line: %d, Total lines: %d, Dir: %d", 
        current_line, line_count, direction))

    local next_line = current_line
    local item = nil

    while true do
        next_line = next_line + direction
        if next_line < 1 or next_line > line_count then
            print("[TaskNav] Reached boundary: " .. next_line)
            break
        end

        local line_text = vim.api.nvim_buf_get_lines(target_buf, next_line - 1, next_line, false)[1]
        item = utils.parse_item(line_text, efm)
        
        if item then
            print(string.format("[TaskNav] FOUND VALID ITEM at line %d: %s", next_line, line_text))
            break
        else
            -- Optional: very verbose, maybe only print if needed
            -- print(string.format("[TaskNav] Line %d invalid: %s", next_line, line_text))
        end
    end

    if not item then
        print("[TaskNav] No more valid items found.")
        vim.notify("No more valid errors in " .. vim.fn.bufname(target_buf), vim.log.levels.INFO)
        return
    end

    vim.b[target_buf].last_nav_line = next_line
    if target_win ~= 0 then
        vim.api.nvim_win_set_cursor(target_win, { next_line, 0 })
    end

    utils.perform_jump(item, vim.api.nvim_get_current_win())
end

return M