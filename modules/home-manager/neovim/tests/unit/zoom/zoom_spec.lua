describe("zoom module", function()
  local old_winlayout = vim.fn.winlayout
  local old_winrestcmd = vim.fn.winrestcmd
  local old_cmd = vim.cmd
  local old_winbufnr = vim.fn.winbufnr
  local old_win_getid = vim.fn.win_getid
  local old_win_gotoid = vim.fn.win_gotoid
  local old_bufexists = vim.fn.bufexists

  local zoom_callback

  before_each(function()
    -- Capture the command
    local old_create_user_command = vim.api.nvim_create_user_command
    vim.api.nvim_create_user_command = function(name, callback)
      if name == "ZoomToggle" then zoom_callback = callback end
    end
    
    package.loaded["zoom"] = nil
    require("zoom")
    vim.api.nvim_create_user_command = old_create_user_command

    -- Default mocks
    vim.fn.winlayout = function() return { "leaf", 1000 } end
    vim.fn.winrestcmd = function() return "resize 10" end
    vim.cmd = function() end
    vim.fn.winbufnr = function() return 1 end
    vim.fn.win_getid = function() return 1000 end
    vim.fn.win_gotoid = function() return 1 end
    vim.fn.bufexists = function() return 1 end
  end)

  after_each(function()
    vim.fn.winlayout = old_winlayout
    vim.fn.winrestcmd = old_winrestcmd
    vim.cmd = old_cmd
    vim.fn.winbufnr = old_winbufnr
    vim.fn.win_getid = old_win_getid
    vim.fn.win_gotoid = old_win_gotoid
    vim.fn.bufexists = old_bufexists
  end)

  it("should maximize (run 'only') on first call", function()
    local cmds = {}
    vim.cmd = function(c) table.insert(cmds, c) end
    
    zoom_callback()
    
    assert.are.equal("only", cmds[1])
  end)

  it("should restore layout on second call", function()
    -- Complex layout: 2 windows in a column
    vim.fn.winlayout = function() 
      return { "col", { { "leaf", 1000 }, { "leaf", 1001 } } }
    end
    vim.fn.winbufnr = function(win) return win == 1000 and 1 or 2 end
    vim.fn.winrestcmd = function() return "RESTORE_CMD" end

    local cmds = {}
    vim.cmd = function(c) table.insert(cmds, c) end

    -- First call: save and maximize
    zoom_callback()
    assert.are.equal("only", cmds[1])
    
    -- Second call: restore
    zoom_callback()
    
    -- Should run 'only', then restore the splits
    assert.are.equal("only", cmds[2])
    
    local found_split = false
    local found_restore = false
    for _, c in ipairs(cmds) do
        if c == "split" then found_split = true end
        if c == "RESTORE_CMD" then found_restore = true end
    end
    
    assert.is_true(found_split)
    assert.is_true(found_restore)
  end)
end)
