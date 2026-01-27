local ansi = require("async.ansi")
local utils = require("async.utils")
local M = {}

---@class Async.Sink.BufferOpts
---@field bufnr? number Existing buffer ID to use
---@field name_fmt? string Format string if no bufnr is provided
---@field efm? string Error format for navigation
---@field winid? number The source window ID to return to when jumping
---@field auto_open? boolean Whether to automatically open the buffer at the bottom
---@field clear? boolean Whether to clear the buffer on start (default: true)

local function parse_item(line, efm)
    if not efm or efm == "" or not line then return nil end
    local qf = vim.fn.getqflist({ lines = { line }, efm = efm })
    local item = qf.items[1]
    if item and item.valid == 1 then
        return item
    end
    return nil
end

local function perform_jump(item, source_win)
    if not item then return end

    local bufnr = item.bufnr == 0 and item.filename ~= "" and vim.fn.bufadd(item.filename) or item.bufnr
    if bufnr ~= 0 then
        local target_win = source_win
        if not target_win or not vim.api.nvim_win_is_valid(target_win) then
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_config(win).relative == "" then
                    target_win = win
                    break
                end
            end
        end

        if target_win then
            vim.api.nvim_set_current_win(target_win)
            vim.api.nvim_win_set_buf(target_win, bufnr)

            -- Restore UI if the target window was previously a sink or inherited muted settings
            if vim.wo[target_win].statuscolumn == "" then
                vim.wo[target_win].statuscolumn = vim.go.statuscolumn
                vim.wo[target_win].relativenumber = vim.go.relativenumber
                vim.wo[target_win].winfixheight = false
            end

            if item.lnum > 0 then
                vim.api.nvim_win_set_cursor(target_win, { item.lnum, math.max(0, item.col - 1) })
                vim.cmd("normal! zz")
            end
        end
    end
end

local function delete_line(bufnr)
    local count = vim.v.count1
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = cursor[1]

    vim.bo[bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(bufnr, line - 1, line - 1 + count, false, {})
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].modified = false

    local new_line_count = vim.api.nvim_buf_line_count(bufnr)
    if line > new_line_count and new_line_count > 0 then
        vim.api.nvim_win_set_cursor(0, { new_line_count, cursor[2] })
    end
end

local function delete_selection(bufnr)
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")

    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end

    vim.bo[bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, {})
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].modified = false

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end

function M.new(opts)
    opts = opts or {}
    if opts.clear == nil then opts.clear = true end
    local bufnr = opts.bufnr
    local processor_factory = opts.processor or require("async.ansi").create_processor
    local processor = nil
    local source_win = opts.winid or vim.api.nvim_get_current_win()
    local opened = false
    local preview_win = nil

    local function close_preview()
        if preview_win and vim.api.nvim_win_is_valid(preview_win) then
            vim.api.nvim_win_close(preview_win, true)
        end
        preview_win = nil
    end

    local function preview_item()
        if not opts.efm then return end
        local line = vim.api.nvim_get_current_line()
        local item = parse_item(line, opts.efm)
        if not (item and item.valid == 1) then return end

        local target_bufnr = item.bufnr == 0 and item.filename ~= "" and vim.fn.bufadd(item.filename) or item.bufnr
        if target_bufnr == 0 then return end

        -- Repair and Bypass Zombie/Swap states
        if not vim.api.nvim_buf_is_loaded(target_bufnr) or vim.bo[target_bufnr].filetype == "" then
            local group = vim.api.nvim_create_augroup("async_preview_swap", { clear = true })
            vim.api.nvim_create_autocmd("SwapExists", {
                group = group,
                callback = function() vim.v.swapchoice = "o" end,
            })
            vim.fn.bufload(target_bufnr)
            vim.api.nvim_del_augroup_by_id(group)

            if vim.bo[target_bufnr].filetype == "" then
                vim.api.nvim_buf_call(target_bufnr, function()
                    vim.cmd("filetype detect")
                end)
            end
        end

        if not (preview_win and vim.api.nvim_win_is_valid(preview_win)) then
            local win = vim.api.nvim_get_current_win()
            local pos = vim.api.nvim_win_get_position(win)
            local width = vim.api.nvim_win_get_width(win)
            local height = math.min(15, pos[1] - 2)
            if height < 1 then height = 1 end

            preview_win = vim.api.nvim_open_win(target_bufnr, false, {
                relative = "editor",
                width = width - 2,
                height = height,
                row = pos[1] - height - 2,
                col = pos[2] + 1,
                border = "rounded",
                zindex = 100,
            })
        end

        if preview_win then
            if vim.api.nvim_win_get_buf(preview_win) ~= target_bufnr then
                vim.api.nvim_win_set_buf(preview_win, target_bufnr)
            end

            vim.api.nvim_win_call(preview_win, function()
                -- Break inheritance from the muted sink
                vim.wo[preview_win].statuscolumn = vim.go.statuscolumn
                vim.wo[preview_win].relativenumber = vim.go.relativenumber
                vim.wo[preview_win].number = true
                vim.wo[preview_win].cursorline = true
                
                local line_count = vim.api.nvim_buf_line_count(target_bufnr)
                local target_line = math.max(1, math.min(item.lnum, line_count))
                vim.api.nvim_win_set_cursor(preview_win, { target_line, 0 })
                vim.cmd("normal! zz")
            end)
        end
    end

    local function open_buffer()
        if not opts.auto_open or opened or not bufnr then return end
        opened = true

        local current_win = vim.api.nvim_get_current_win()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == bufnr then return end
        end

        vim.cmd("botright sbuffer " .. bufnr)
        vim.api.nvim_win_set_height(0, 10)
        
        -- Apply performance settings ONLY to the sink window
        local win = vim.api.nvim_get_current_win()
        vim.wo[win].statuscolumn = ""
        vim.wo[win].relativenumber = false
        vim.wo[win].winfixheight = true

        if vim.api.nvim_win_is_valid(current_win) then
            vim.api.nvim_set_current_win(current_win)
        end
    end

    local buffer_handler = utils.line_buffered(function(lines, is_exit, exit_obj)
        if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then return end

        vim.bo[bufnr].modifiable = true

        if #lines > 0 then
            local start_line = vim.api.nvim_buf_line_count(bufnr)
            if start_line == 1 and vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == "" then
                start_line = 0
            end

            local windows_to_scroll = {}
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == bufnr and vim.api.nvim_win_get_cursor(win)[1] == vim.api.nvim_buf_line_count(bufnr) then
                    table.insert(windows_to_scroll, win)
                end
            end

            local clean_lines, highlights = {}, {}
            for i, raw_line in ipairs(lines) do
                local clean, line_hls = processor.process_line(raw_line)
                if clean then
                    table.insert(clean_lines, clean)
                    local current_line_idx = start_line + #clean_lines - 1
                    for _, hl in ipairs(line_hls) do
                        table.insert(highlights, { current_line_idx, hl[1], hl[2], hl[3] })
                    end
                end
            end

            if start_line == 0 then
                vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, clean_lines)
            else
                vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, clean_lines)
            end

            for _, hl in ipairs(highlights) do
                vim.api.nvim_buf_add_highlight(bufnr, processor.ns, hl[4], hl[1], hl[2], hl[3])
            end

            local last_line = vim.api.nvim_buf_line_count(bufnr)
            for _, win in ipairs(windows_to_scroll) do
                vim.api.nvim_win_set_cursor(win, { last_line, 0 })
            end

            if vim.api.nvim_buf_line_count(bufnr) > 1 then
                open_buffer()
            end
        end

        if is_exit then
            local count = vim.api.nvim_buf_line_count(bufnr)
            if count == 1 and not opened then
                local content = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
                local item = parse_item(content, opts.efm)
                if item then
                    perform_jump(item, source_win)
                else
                    open_buffer()
                end
            elseif (count > 0 and not opened) or opened then
                open_buffer()
            end
        end

        vim.bo[bufnr].modifiable = false
        vim.bo[bufnr].modified = false
    end)

    return {
        validate = function()
            if opts.bufnr and not vim.api.nvim_buf_is_valid(opts.bufnr) then
                return false, string.format("Buffer %d is not valid", opts.bufnr)
            end
            return true
        end,
        on_start = function(task)
            if not bufnr then
                local buf_name = string.format(opts.name_fmt or "//sink/%s/%s", table.concat(task.cmd, "_"), task.pid)
                bufnr = vim.api.nvim_create_buf(true, true) -- listed = true
                vim.api.nvim_buf_set_name(bufnr, buf_name)
            elseif opts.clear then
                vim.bo[bufnr].modifiable = true
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
            end

            vim.bo[bufnr].buftype = "nofile"
            vim.bo[bufnr].bufhidden = "hide"
            vim.bo[bufnr].swapfile = false
            vim.bo[bufnr].undolevels = -1
            vim.bo[bufnr].modifiable = false
            vim.bo[bufnr].modified = false
            
            processor = processor_factory(bufnr, opts.processor_opts)
            
            vim.keymap.set("n", "dd", function() delete_line(bufnr) end, { buffer = bufnr, desc = "Delete line" })
            vim.keymap.set("v", "d", function() delete_selection(bufnr) end, { buffer = bufnr, desc = "Delete selection" })
            vim.keymap.set("n", "q", function() close_preview(); vim.cmd("bdelete") end, { buffer = bufnr, desc = "Close buffer and preview" })

            if opts.efm then
                vim.keymap.set("n", "<CR>", function()
                    close_preview()
                    local line = vim.api.nvim_get_current_line()
                    local item = parse_item(line, opts.efm)
                    perform_jump(item, source_win)
                end, { buffer = bufnr, desc = "Jump to error" })
                vim.keymap.set("n", "P", function()
                    if preview_win and vim.api.nvim_win_is_valid(preview_win) then
                        close_preview()
                    else
                        preview_item()
                    end
                end, { buffer = bufnr, desc = "Toggle floating preview" })

                vim.api.nvim_create_autocmd("CursorMoved", {
                    buffer = bufnr,
                    callback = function()
                        if preview_win and vim.api.nvim_win_is_valid(preview_win) then
                            preview_item()
                        end
                    end,
                })

                vim.api.nvim_create_autocmd("BufLeave", {
                    buffer = bufnr,
                    callback = close_preview,
                })
            end
        end,
        on_stdout = function(_, data) buffer_handler(data, false) end,
        on_stderr = function(_, data) buffer_handler(data, false) end,
        on_exit = function(_, obj) buffer_handler(obj, true) end,
    }
end

return M
