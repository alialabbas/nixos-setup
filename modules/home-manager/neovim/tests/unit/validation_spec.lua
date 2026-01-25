local async = require("async")

describe("Validation", function()
  it("should fail to run if a sink validation fails", function()
    -- Create and delete a buffer to get an invalid ID
    local b = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_delete(b, { force = true })
    
    local ok, err = pcall(function()
      async.run("echo hello", {
        sinks = {
          async.sinks.buffer.new({ bufnr = b })
        }
      })
    end)
    
    assert.is_false(ok)
    assert.truthy(err:match("Task validation failed"))
  end)

  it("should succeed with valid buffer IDs", function()
    local b = vim.api.nvim_create_buf(false, true)
    local pid = async.run("echo hello", {
      sinks = {
        async.sinks.buffer.new({ bufnr = b })
      }
    })
    
    assert.truthy(pid)
    
    vim.wait(1000, function() return #async.list() == 0 end)
    vim.api.nvim_buf_delete(b, { force = true })
  end)
end)
