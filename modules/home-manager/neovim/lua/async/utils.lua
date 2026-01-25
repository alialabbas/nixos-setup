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

return M