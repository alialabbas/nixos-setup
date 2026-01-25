local async = require("async")

describe("Async Lua Tasks (Simplified)", function()
  it("should run a lua function and complete via task.complete", function()
    local completed = false
    async.run(function(emit, task)
      completed = true
      task.complete()
    end)

    vim.wait(1000, function() return #async.list() == 0 end)
    assert.is_true(completed)
  end)

  it("should emit data to sinks", function()
    local b = vim.api.nvim_create_buf(false, true)
    async.run(function(emit, task)
      emit("hello from lua")
      emit("second line")
      task.complete()
    end, {
      sinks = { async.sinks.buffer.new({ bufnr = b }) }
    })

    vim.wait(1000, function() return #async.list() == 0 end)

    local lines = vim.api.nvim_buf_get_lines(b, 0, -1, false)
    local content = table.concat(lines, "\n")
    assert.truthy(content:match("hello from lua"))
    assert.truthy(content:match("second line"))

    vim.api.nvim_buf_delete(b, { force = true })
  end)

  it("should handle async callbacks via task.complete", function()
    local b = vim.api.nvim_create_buf(false, true)
    async.run(function(emit, task)
      vim.defer_fn(function()
        emit("delayed message")
        task.complete()
      end, 10)
    end, {
      sinks = { async.sinks.buffer.new({ bufnr = b }) }
    })

    vim.wait(1000, function() return #async.list() == 0 end)

    local lines = vim.api.nvim_buf_get_lines(b, 0, -1, false)
    local content = table.concat(lines, "\n")
    assert.truthy(content:match("delayed message"))

    vim.api.nvim_buf_delete(b, { force = true })
  end)

  it("should handle lua errors gracefully", function()
    local b = vim.api.nvim_create_buf(false, true)
    async.run(function()
      error("something went wrong")
    end, {
      sinks = { async.sinks.buffer.new({ bufnr = b }) }
    })

    vim.wait(1000, function() return #async.list() == 0 end)

    local lines = vim.api.nvim_buf_get_lines(b, 0, -1, false)
    local content = table.concat(lines, "\n")
    assert.truthy(content:match("%[Lua Error%]"))
    assert.truthy(content:match("something went wrong"))

    vim.api.nvim_buf_delete(b, { force = true })
  end)
end)