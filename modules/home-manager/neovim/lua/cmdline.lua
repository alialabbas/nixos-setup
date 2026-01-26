local M = {}
local win_id = nil
local buf_id = nil
local last_cmd = ""
local current_list = {}
local show_timer = vim.uv.new_timer()

local config = {
    min_width = 40,
    max_width = 100,
    max_height = 12,
    border = 'rounded',
    highlight = {
        window = 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel',
    }
}

function M.show()
    local cmd = vim.fn.getcmdline()
    local cmd_type = vim.fn.getcmdtype()

    if cmd_type ~= ':' or #cmd == 0 then
        M.close()
        return
    end

    -- Determine if we are typing or cycling
    -- Typing: length changes by 1, or it's a completely different string
    -- Cycling: the new cmd matches one of our existing completion candidates
    local is_cycling = false
    for _, item in ipairs(current_list) do
        if cmd:sub(- #item) == item then
            is_cycling = true
            break
        end
    end

    -- If we aren't cycling, or the command was shortened (backspace), refresh the list
    if not is_cycling or #cmd < #last_cmd then
        local results = vim.fn.getcompletion(cmd, 'cmdline')
        if #results == 0 then
            results = vim.fn.getcompletion(cmd .. '*', 'cmdline')
        end

        if #results == 0 then
            M.close()
            return
        end

        current_list = results
        last_cmd = cmd

        -- Update Buffer Content
        if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
            buf_id = vim.api.nvim_create_buf(false, true)
        end

        local lines = {}
        for _, res in ipairs(current_list) do
            table.insert(lines, string.format(" %s ", res))
        end
        vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
    end

    -- Find the active selection in our locked list
    local selected_idx = nil
    local max_match_len = -1
    for i, item in ipairs(current_list) do
        if cmd:sub(- #item) == item then
            -- Prefer the longest match to handle cases like 'sparse-checkout' vs 'checkout'
            if #item > max_match_len then
                selected_idx = i
                max_match_len = #item
            end
        end
    end

    -- Window Geometry
    local height = math.min(#current_list, config.max_height)
    local max_l = 0
    if not win_id then -- Only calculate width on first open to prevent jitter
        for _, l in ipairs(current_list) do
            max_l = math.max(max_l, #l + 4)
        end
    end

    local width = win_id and vim.api.nvim_win_get_width(win_id) or
    math.min(math.max(max_l, config.min_width), config.max_width)
    local row = math.max(0, vim.o.lines - height - 3)

    local opts = {
        relative = 'editor',
        row = row,
        col = 2,
        width = width,
        height = height,
        style = 'minimal',
        border = config.border,
        focusable = false,
        noautocmd = true,
        zindex = 250,
    }

    if not win_id or not vim.api.nvim_win_is_valid(win_id) then
        win_id = vim.api.nvim_open_win(buf_id, false, opts)
        vim.api.nvim_set_option_value('winhl', config.highlight.window, { win = win_id })
    else
        vim.api.nvim_win_set_config(win_id, opts)
    end

    -- Move cursor to selection (Neovim handles scrolling automatically)
    if selected_idx then
        vim.api.nvim_win_set_cursor(win_id, { selected_idx, 0 })
        vim.api.nvim_set_option_value('cursorline', true, { win = win_id })
    else
        vim.api.nvim_set_option_value('cursorline', false, { win = win_id })
    end

    vim.cmd('redraw')
end

function M.close()
    if win_id and vim.api.nvim_win_is_valid(win_id) then
        vim.api.nvim_win_close(win_id, true)
    end
    win_id = nil
    current_list = {}
    last_cmd = ""
    vim.cmd('redraw')
end

function M.setup()
    -- Native behavior: prefix completion first, then full cycle
    vim.opt.wildmenu = false
    vim.opt.wildmode = "longest:full,full"
    vim.opt.wildoptions = ""

    local group = vim.api.nvim_create_augroup('cmdline_ui', { clear = true })

    vim.api.nvim_create_autocmd('CmdlineChanged', {
        group = group,
        callback = function()
            show_timer:stop()
            show_timer:start(20, 0, vim.schedule_wrap(function()
                if vim.fn.getcmdtype() == ':' then
                    M.show()
                end
            end))
        end
    })

    vim.api.nvim_create_autocmd('CmdlineLeave', {
        group = group,
        callback = function()
            show_timer:stop()
            M.close()
        end
    })
end

M.setup()

return M
