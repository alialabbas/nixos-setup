local menu = require('ui.menu')
local M = {}

---Override vim.ui.select with a custom menu
---@param items any[]
---@param opts? {prompt?: string, format_item?: fun(item: any): string}
---@param on_choice fun(item: any|nil, idx: number|nil)
function vim.ui.select(items, opts, on_choice)
    opts = opts or {}
    local prompt = opts.prompt or "Select one of:"
    local format_item = opts.format_item or tostring

    local formatted_items = {}
    for _, item in ipairs(items) do
        table.insert(formatted_items, format_item(item))
    end

    local width = 0
    for _, item in ipairs(formatted_items) do
        width = math.max(width, #item)
    end
    width = math.max(width, #prompt, 60) + 4
    width = math.min(width, math.floor(vim.o.columns * 0.8))

    local height = math.min(#formatted_items, math.floor(vim.o.lines * 0.6))
    height = math.max(height, 1)

    local ui = menu.new({
        min_width = width,
        max_height = height,
        title = " " .. prompt .. " ",
        focusable = true,
    })

    ui:open(formatted_items, {
        relative = 'editor',
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        width = width,
        height = height,
        focusable = true,
    })

    local bufnr = ui.buf_id
    local winid = ui.win_id

    local function close()
        ui:close()
    end

    local function confirm()
        local idx = vim.api.nvim_win_get_cursor(winid)[1]
        close()
        on_choice(items[idx], idx)
    end

    vim.keymap.set('n', '<CR>', confirm, { buffer = bufnr, silent = true })
    vim.keymap.set('n', '<Esc>', function() close(); on_choice(nil, nil) end, { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'q', function() close(); on_choice(nil, nil) end, { buffer = bufnr, silent = true })

    -- Focus the window
    vim.api.nvim_set_current_win(winid)
end

---Override vim.ui.input with a custom floating window
---@param opts? {prompt?: string, default?: string}
---@param on_confirm fun(value: string|nil)
function vim.ui.input(opts, on_confirm)
    opts = opts or {}
    local prompt = opts.prompt or "Input:"
    local default = opts.default or ""

    local buf = vim.api.nvim_create_buf(false, true)
    local width = math.max(#prompt + #default + 10, 40)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        row = math.floor(vim.o.lines / 2) - 1,
        col = math.floor(vim.o.columns / 2) - math.floor(width / 2),
        width = width,
        height = 1,
        style = 'minimal',
        border = 'rounded',
        title = " " .. prompt .. " ",
        title_pos = 'center',
    })

    vim.api.nvim_set_option_value('winhl', 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder', { win = win })
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { default })

    if default ~= "" then
        vim.api.nvim_win_set_cursor(win, { 1, #default })
    end

    vim.cmd('startinsert!')

    local function confirm()
        local value = vim.trim(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1])
        vim.api.nvim_win_close(win, true)
        vim.cmd('stopinsert')
        on_confirm(value)
    end

    local function cancel()
        vim.api.nvim_win_close(win, true)
        vim.cmd('stopinsert')
        on_confirm(nil)
    end

    vim.keymap.set('i', '<CR>', confirm, { buffer = buf, silent = true })
    vim.keymap.set('i', '<Esc>', cancel, { buffer = buf, silent = true })
    vim.keymap.set('n', '<CR>', confirm, { buffer = buf, silent = true })
    vim.keymap.set('n', '<Esc>', cancel, { buffer = buf, silent = true })
    vim.keymap.set('n', 'q', cancel, { buffer = buf, silent = true })
end

return M
