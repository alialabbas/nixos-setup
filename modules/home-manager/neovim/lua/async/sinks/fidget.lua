local M = {}

---@param opts? table
function M.new(opts)
  local handle = nil

  return {
    on_start = function(task)
      local ok, fidget = pcall(require, "fidget")
      if not ok then return end

      -- Use the first word of the command as the title (e.g., 'rg', 'make')
      local cmd_name = task.name:match("^%S+") or "Task"
      
      handle = fidget.progress.handle.create({
        title = cmd_name:sub(1, 1):upper() .. cmd_name:sub(2), -- Capitalize (e.g. 'Rg')
        message = "Running...",
        lsp_client = { name = "AsyncNvim" },
      })
    end,
    on_stdout = function(task, data)
      -- Keep it silent to avoid UI flickering and performance hits
    end,
    on_stderr = function(task, data)
      if handle then
        handle:report({ message = "Running (with stderr)..." })
      end
    end,
    on_exit = function(task, obj)
      local h = handle -- Capture handle for the closure
      if h then
        if obj.code == 0 then
          h:report({ message = "Done" })
          h:finish()
        else
          h:report({ message = string.format("Failed (code %d)", obj.code) })
          -- Stay for 3 seconds so the user sees the error regardless of cause
          vim.defer_fn(function() h:finish() end, 3000)
        end
        handle = nil
      end
    end
  }
end

return M
