local async_completion = require("async.completion")

describe("async.completion", function()
  local old_system = vim.fn.system
  local old_executable = vim.fn.executable

  before_each(function()
    vim.fn.executable = function() return 1 end
    vim.fn.system = function() return "" end
  end)

  after_each(function()
    vim.fn.system = old_system
    vim.fn.executable = old_executable
  end)

  it("should use fish for completion if available", function()
    vim.fn.executable = function(cmd) return cmd == "fish" and 1 or 0 end
    
    local captured_cmds = {}
    vim.fn.system = function(cmd)
      table.insert(captured_cmds, cmd)
      return "checkout\tbranch description\ncommit\tmessage description"
    end

    -- We need to reload to pick up the has_fish change if it's top-level
    -- But in completion.lua it is top-level: local has_fish = vim.fn.executable("fish") == 1
    package.loaded["async.completion"] = nil
    async_completion = require("async.completion")

    local results = async_completion.shell_complete("git che", "che")
    
    assert.are.same({ "checkout", "commit" }, results)
    assert.is_true(captured_cmds[1]:find("fish -c", 1, true) ~= nil)
  end)

  it("should fallback to bash if fish is missing", function()
    vim.fn.executable = function(cmd) return 0 end
    
    vim.fn.system = function(cmd)
      if type(cmd) == "table" and cmd[1] == "bash" then
        return "file1.txt\nfile2.txt\n"
      end
      return ""
    end

    package.loaded["async.completion"] = nil
    async_completion = require("async.completion")

    local results = async_completion.shell_complete("ls f", "f")
    
    assert.are.same({ "file1.txt", "file2.txt" }, results)
  end)
end)
