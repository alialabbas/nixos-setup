local M = {}

---Creates a line-buffered wrapper around a callback
---@param callback fun(lines: string[], is_exit: boolean, exit_obj?: any)
---@return fun(data: string|any, is_exit: boolean)
function M.line_buffered(callback)
  local partial = ""
  return function(data, is_exit)
    if is_exit then
      local lines = {}
      if partial ~= "" then
        table.insert(lines, partial)
      end
      callback(lines, true, data)
      partial = ""
      return
    end

    local text = partial .. (data:gsub("\r\n", "\n"))
    local lines = vim.split(text, "\n")

    if not text:match("\n$") then
      partial = table.remove(lines)
    else
      partial = ""
      if lines[#lines] == "" then table.remove(lines) end
    end

    if #lines > 0 then
      callback(lines, false)
    end
  end
end

---Parse a line using errorformat
---@param line string
---@param efm string
---@return table|nil
function M.parse_item(line, efm)
    if not efm or efm == "" or not line then return nil end
    local qf = vim.fn.getqflist({ lines = { line }, efm = efm })
    local item = qf.items[1]
    if item and item.valid == 1 then
        return item
    end
    return nil
end

---Perform a jump to a quickfix-like item
---@param item table
---@param source_win? number
function M.perform_jump(item, source_win)
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

            if vim.wo[target_win].statuscolumn == "" then
                vim.wo[target_win].statuscolumn = vim.go.statuscolumn
                vim.wo[target_win].relativenumber = vim.go.relativenumber
                vim.wo[target_win].winfixheight = false
            end

            if item.lnum > 0 then
                local line_count = vim.api.nvim_buf_line_count(bufnr)
                local target_line = math.min(item.lnum, math.max(1, line_count))
                vim.api.nvim_win_set_cursor(target_win, { target_line, math.max(0, item.col - 1) })
                vim.cmd("normal! zz")
            end
        end
    end
end

return M