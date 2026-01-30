describe("terminal module", function()
  local old_create_user_command = vim.api.nvim_create_user_command
  local old_bufnr = vim.fn.bufnr
  local old_buf_is_valid = vim.api.nvim_buf_is_valid
  local old_cmd = vim.cmd
  local old_buf_set_name = vim.api.nvim_buf_set_name
  local old_getcwd = vim.fn.getcwd
  local old_set_current_buf = vim.api.nvim_set_current_buf
  local old_chan_send = vim.api.nvim_chan_send
  local old_filereadable = vim.fn.filereadable

  local term_command_callback

  before_each(function()
    -- Mock nvim_create_user_command to capture the callback
    vim.api.nvim_create_user_command = function(name, callback, opts)
      if name == "Term" then
        term_command_callback = callback
      end
    end

    -- Reload module to trigger command creation
    package.loaded["terminal"] = nil
    require("terminal")

    -- Mocks
    vim.fn.bufnr = function() return -1 end
    vim.api.nvim_buf_is_valid = function() return false end
    vim.cmd = function() end
    vim.api.nvim_buf_set_name = function() return true end
    vim.fn.getcwd = function() return "/dummy/cwd" end
    vim.api.nvim_set_current_buf = function() end
    vim.api.nvim_chan_send = function() end
    vim.fn.filereadable = function() return 0 end
    
    -- Mock vim.opt_local
    _G.vim.opt_local = { number = true, relativenumber = true, statuscolumn = "foo" }
  end)

  after_each(function()
    vim.api.nvim_create_user_command = old_create_user_command
    vim.fn.bufnr = old_bufnr
    vim.api.nvim_buf_is_valid = old_buf_is_valid
    vim.cmd = old_cmd
    vim.api.nvim_buf_set_name = old_buf_set_name
    vim.fn.getcwd = old_getcwd
    vim.api.nvim_set_current_buf = old_set_current_buf
    vim.api.nvim_chan_send = old_chan_send
    vim.fn.filereadable = old_filereadable
  end)

  it("should register Term command", function()
    assert.is_function(term_command_callback)
  end)

  it("Term with no args should create a new terminal with unique name", function()
    local captured_cmd
    vim.cmd = function(c) captured_cmd = c end

    local captured_name
    vim.api.nvim_buf_set_name = function(buf, name) captured_name = name end

    term_command_callback({ fargs = {} })

    assert.are.equal("terminal", captured_cmd)
    assert.is_true(captured_name:match("^term:///dummy/cwd//%d+-%d+$") ~= nil)
  end)

  it("Term <name> should create a new terminal with specific name", function()
    local captured_name
    vim.api.nvim_buf_set_name = function(buf, name) captured_name = name end

    term_command_callback({ fargs = { "mytask" } })

    assert.are.equal("term:///dummy/cwd//mytask", captured_name)
  end)

  it("Term <name> <cmd> should create a new terminal running cmd", function()
    local captured_cmd
    vim.cmd = function(c) captured_cmd = c end

    term_command_callback({ fargs = { "mytask", "ls", "-la" } })

    assert.are.equal("terminal ls -la", captured_cmd)
  end)

  it("Term <name> should switch to existing buffer if it exists", function()
    local existing_bufnr = 123
    vim.fn.bufnr = function(name)
      if name == "term:///dummy/cwd//mytask" then return existing_bufnr end
      return -1
    end
    vim.api.nvim_buf_is_valid = function(buf) return buf == existing_bufnr end

    local switched_to_buf
    vim.api.nvim_set_current_buf = function(buf) switched_to_buf = buf end

    term_command_callback({ fargs = { "mytask" } })

    assert.are.equal(existing_bufnr, switched_to_buf)
  end)

  it("should source .env if present and no command specified", function()
    vim.fn.filereadable = function(path)
      if path == ".env" then return 1 end
      return 0
    end
    
    local sent_data = ""
    vim.api.nvim_chan_send = function(chan, data) sent_data = data end
    
    -- Mock channel ID
    _G.vim.bo = { channel = 5 }

    term_command_callback({ fargs = { "envtest" } })

    assert.is_true(sent_data:match("source .env") ~= nil)
  end)
end)
