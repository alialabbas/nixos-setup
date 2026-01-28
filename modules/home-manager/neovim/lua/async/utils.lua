local M = {}

---Creates a line-buffered wrapper around a callback
---@param callback fun(lines: string[], is_exit: boolean, exit_obj?: table)
---@return fun(data: string|table, is_exit: boolean)
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
                vim.api.nvim_win_set_cursor(target_win, { item.lnum, math.max(0, item.col - 1) })
                vim.cmd("normal! zz")
            end
        end
    end
end

return M