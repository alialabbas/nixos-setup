local rooter

describe("rooter module", function()
  local old_buf_get_name = vim.api.nvim_buf_get_name
  local old_glob = vim.fn.glob
  local old_getcwd = vim.fn.getcwd
  local old_cmd = vim.cmd
  local old_bo = vim.bo

  before_each(function()
    package.loaded["rooter"] = nil
    -- Mock necessary functions
    vim.api.nvim_buf_get_name = function() return "" end
    vim.fn.glob = function() return "" end
    vim.fn.getcwd = function() return "/current/working/dir" end
    vim.cmd = function() end
    -- We use a raw table for vim.bo in tests
    _G.vim.bo = { buftype = "", filetype = "" }
    
    rooter = require("rooter")
  end)

  after_each(function()
    vim.api.nvim_buf_get_name = old_buf_get_name
    vim.fn.glob = old_glob
    vim.fn.getcwd = old_getcwd
    vim.cmd = old_cmd
    _G.vim.bo = old_bo
  end)

  it("should not change directory if no root is found", function()
    local cmd_called = false
    vim.cmd = function(c) cmd_called = true end
    
    rooter.root()
    assert.is_false(cmd_called)
  end)

  it("should change directory to Layer 2 marker if found", function()
    vim.api.nvim_buf_get_name = function() return "/home/user/project/src/file.lua" end
    
    -- Mock glob to find .git in /home/user/project
    vim.fn.glob = function(pattern)
      if pattern == "/home/user/project/.git" then
        return "/home/user/project/.git"
      end
      return ""
    end

    local captured_cmd
    vim.cmd = function(c) captured_cmd = c end

    rooter.root()
    assert.are.equal("tcd /home/user/project", captured_cmd)
  end)

  it("should change directory to Layer 1 marker if Layer 2 is not found", function()
    vim.api.nvim_buf_get_name = function() return "/home/user/project/src/file.lua" end
    
    -- Mock glob to find go.mod in /home/user/project
    vim.fn.glob = function(pattern)
      if pattern == "/home/user/project/go.mod" then
        return "/home/user/project/go.mod"
      end
      return ""
    end

    local captured_cmd
    vim.cmd = function(c) captured_cmd = c end

    rooter.root()
    assert.are.equal("tcd /home/user/project", captured_cmd)
  end)

  it("should prioritize Layer 2 over Layer 1", function()
    vim.api.nvim_buf_get_name = function() return "/home/user/project/src/file.lua" end
    
    vim.fn.glob = function(pattern)
      if pattern == "/home/user/project/src/go.mod" then
        return pattern
      end
      if pattern == "/home/user/project/.git" then
        return pattern
      end
      return ""
    end

    local captured_cmd
    vim.cmd = function(c) captured_cmd = c end

    rooter.root()
    -- Even though go.mod is in /home/user/project/src (deeper), .git in /home/user/project should be found as it's checked first in each level
    -- Wait, it checks /home/user/project/src first. 
    -- In /home/user/project/src: checks .git (no), checks go.mod (yes, root_layer1 = /home/user/project/src)
    -- In /home/user/project: checks .git (yes, returns /home/user/project)
    assert.are.equal("tcd /home/user/project", captured_cmd)
  end)

  it("should take the deepest Layer 1 marker if no Layer 2 exists", function()
    vim.api.nvim_buf_get_name = function() return "/home/user/project/sub/src/file.lua" end
    
    vim.fn.glob = function(pattern)
      if pattern == "/home/user/project/sub/src/Makefile" then return pattern end
      if pattern == "/home/user/project/go.mod" then return pattern end
      return ""
    end

    local captured_cmd
    vim.cmd = function(c) captured_cmd = c end

    rooter.root()
    assert.are.equal("tcd /home/user/project/sub/src", captured_cmd)
  end)

  it("should handle oil:// buffers", function()
    vim.api.nvim_buf_get_name = function() return "oil:///home/user/project/src/" end
    _G.vim.bo.filetype = "oil"
    
    vim.fn.glob = function(pattern)
        if pattern == "/home/user/project/.git" then return pattern end
        return ""
    end

    local captured_cmd
    vim.cmd = function(c) captured_cmd = c end

    rooter.root()
    assert.are.equal("tcd /home/user/project", captured_cmd)
  end)
end)
