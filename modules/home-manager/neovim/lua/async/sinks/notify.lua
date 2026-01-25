local ansi = require("async.ansi")
local M = {}

---@param opts? table
function M.new(opts)
  return {
    on_start = function(task)
      vim.notify(string.format("Task started: %s", table.concat(task.cmd, " ")), vim.log.levels.INFO)
    end,
    on_exit = function(task, obj)
      local level = obj.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
      local cmd_str = ansi.strip(table.concat(task.cmd, " "))
      vim.notify(string.format("Task finished: %s (code %d)", cmd_str, obj.code), level)
    end
  }
end

return M