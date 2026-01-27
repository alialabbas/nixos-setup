local M = {}

function M.new(opts)
    local self = setmetatable({}, { __index = M })
    self.config = vim.tbl_deep_extend("force", {
        min_width = 40,
        max_height = 12,
        border = 'rounded',
        highlight = 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel',
    }, opts or {})
    self.win_id = nil
    self.buf_id = nil
    self.ns_id = vim.api.nvim_create_namespace("ui_menu")
    return self
end

function M:open(items, geometry)
    if not items or #items == 0 then
        self:close()
        return
    end

    if not self.buf_id or not vim.api.nvim_buf_is_valid(self.buf_id) then
        self.buf_id = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_option_value('buftype', 'nofile', { buf = self.buf_id })
    end

    local lines = {}
    local highlights = {}
    local max_l = 0
    
    for i, item in ipairs(items) do
        local text = type(item) == "string" and item or item.text
        table.insert(lines, text)
        max_l = math.max(max_l, #text + 2)
        
        if type(item) == "table" and item.highlights then
            for _, hl in ipairs(item.highlights) do
                table.insert(highlights, { i - 1, hl.group, hl.start_col, hl.end_col })
            end
        end
    end

    pcall(function()
        vim.api.nvim_set_option_value('modifiable', true, { buf = self.buf_id })
        vim.api.nvim_buf_set_lines(self.buf_id, 0, -1, false, lines)
        vim.api.nvim_buf_clear_namespace(self.buf_id, self.ns_id, 0, -1)
        for _, hl in ipairs(highlights) do
            vim.api.nvim_buf_add_highlight(self.buf_id, self.ns_id, hl[2], hl[1], hl[3], hl[4])
        end
        vim.api.nvim_set_option_value('modifiable', false, { buf = self.buf_id })
    end)

    local height = math.min(#items, self.config.max_height)
    local width = math.max(self.config.min_width, math.min(max_l, vim.o.columns - 5))
    
    local win_opts = vim.tbl_deep_extend("force", {
        relative = 'editor',
        width = width,
        height = height,
        style = 'minimal',
        border = self.config.border,
        focusable = false,
        noautocmd = true,
        zindex = 250,
    }, geometry or {})

    pcall(function()
        if not self.win_id or not vim.api.nvim_win_is_valid(self.win_id) then
            self.win_id = vim.api.nvim_open_win(self.buf_id, false, win_opts)
            vim.api.nvim_set_option_value('winhl', self.config.highlight, { win = self.win_id })
        else
            vim.api.nvim_win_set_config(self.win_id, win_opts)
        end
    end)
end

function M:set_cursor(idx)
    if self.win_id and vim.api.nvim_win_is_valid(self.win_id) then
        pcall(function()
            if idx and idx > 0 then
                vim.api.nvim_win_set_cursor(self.win_id, { idx, 0 })
                vim.api.nvim_set_option_value('cursorline', true, { win = self.win_id })
            else
                vim.api.nvim_set_option_value('cursorline', false, { win = self.win_id })
            end
        end)
    end
end

function M:close()
    if self.win_id and vim.api.nvim_win_is_valid(self.win_id) then
        pcall(vim.api.nvim_win_close, self.win_id, true)
    end
    self.win_id = nil
end

return M
