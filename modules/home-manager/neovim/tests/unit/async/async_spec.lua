local async = require("async")

describe("Async Engine", function()
  it("should run a command and return a PID", function()
    local pid = async.run("echo 'hello world'")
    assert.are.equal("number", type(pid))
    assert.truthy(pid > 0)
    
    -- Wait for it to finish
    vim.wait(2000, function() return #async.list() == 0 end)
  end)

  it("should track running tasks in the list", function()
    local pid = async.run("sleep 0.5")
    local list = async.list()
    
    local found = false
    for _, t in ipairs(list) do
      if t.pid == pid then found = true end
    end
    assert.is_true(found)
    
    vim.wait(2000, function() return #async.list() == 0 end)
  end)

  it("should stop a running task", function()
    local pid = async.run("sleep 10")
    assert.truthy(pid)
    
    async.stop(pid)
    
    local stopped = vim.wait(2000, function()
      return #async.list() == 0
    end)
    
    assert.is_true(stopped)
  end)

  it("should output to a buffer sink", function()
    local b = vim.api.nvim_create_buf(false, true)
    async.run("echo 'test output'", {
      sinks = { async.sinks.buffer.new({ bufnr = b }) }
    })
    
    -- Increase timeout and check state
    local finished = vim.wait(3000, function() return #async.list() == 0 end)
    if not finished then
      print("Task failed to finish in time")
    end
    
    local lines = vim.api.nvim_buf_get_lines(b, 0, -1, false)
    local content = table.concat(lines, "\n")
    
    if not content:match("test output") then
      print("Buffer Content DEBUG:\n" .. content)
    end

    assert.truthy(content:match("test output"))
    
    vim.api.nvim_buf_delete(b, { force = true })
  end)

  it("should handle navigation in buffers via efm", function()
    local b = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_get_current_win()
    
    async.run("echo 'file.txt:10: error message'", {
      sinks = { 
        async.sinks.buffer.new({ 
          bufnr = b, 
          efm = "%f:%l: %m",
          winid = win
        }) 
      }
    })
    
    vim.wait(2000, function() return #async.list() == 0 end)
    
    local maps = vim.api.nvim_buf_get_keymap(b, "n")
    local found_cr = false
    for _, m in ipairs(maps) do
      if m.lhs == "<CR>" then found_cr = true end
    end
    assert.is_true(found_cr)
    
    vim.api.nvim_buf_delete(b, { force = true })
  end)
end)