local async_controller = require("async.controller")
local async_utils = require("async.utils")

describe("async.controller", function()
  local old_list_bufs = vim.api.nvim_list_bufs
  local old_buf_is_valid = vim.api.nvim_buf_is_valid
  local old_buf_get_name = vim.api.nvim_buf_get_name
  local old_getcwd = vim.fn.getcwd
  local old_fnamemodify = vim.fn.fnamemodify
  local old_getbufinfo = vim.fn.getbufinfo
  local old_win_findbuf = vim.fn.win_findbuf
  local old_buf_line_count = vim.api.nvim_buf_line_count
  local old_buf_get_lines = vim.api.nvim_buf_get_lines
  local old_parse_item = async_utils.parse_item
  local old_perform_jump = async_utils.perform_jump
  local old_notify = vim.notify
  local old_get_current_win = vim.api.nvim_get_current_win

  before_each(function()
    vim.api.nvim_list_bufs = function() return { 1, 2 } end
    vim.api.nvim_buf_is_valid = function() return true end
    vim.api.nvim_buf_get_name = function(b) 
        if b == 1 then return "/work/project//task/make/project" end
        return "/work/other//task/make/other"
    end
    vim.fn.getcwd = function() return "/work/project" end
    vim.fn.fnamemodify = function(p, m) 
        if m == ":t" then return "project" end
        return p
    end
    vim.fn.getbufinfo = function(b) return { { lastused = 100 } } end
    vim.fn.win_findbuf = function() return {} end
    vim.api.nvim_buf_line_count = function() return 10 end
    vim.api.nvim_buf_get_lines = function() return { "line text" } end
    async_utils.parse_item = function() return nil end
    async_utils.perform_jump = function() end
    vim.notify = function() end
    vim.api.nvim_get_current_win = function() return 100 end
  end)

  after_each(function()
    vim.api.nvim_list_bufs = old_list_bufs
    vim.api.nvim_buf_is_valid = old_buf_is_valid
    vim.api.nvim_buf_get_name = old_buf_get_name
    vim.fn.getcwd = old_getcwd
    vim.fn.fnamemodify = old_fnamemodify
    vim.fn.getbufinfo = old_getbufinfo
    vim.fn.win_findbuf = old_win_findbuf
    vim.api.nvim_buf_line_count = old_buf_line_count
    vim.api.nvim_buf_get_lines = old_buf_get_lines
    async_utils.parse_item = old_parse_item
    async_utils.perform_jump = old_perform_jump
    vim.notify = old_notify
    vim.api.nvim_get_current_win = old_get_current_win
  end)

  it("should navigate to next valid item", function()
    -- Mocking for buffer 1 (project buffer)
    vim.api.nvim_buf_line_count = function(b) return 3 end
    vim.api.nvim_buf_get_lines = function(b, s, e)
        if s == 0 then return { "invalid 1" } end
        if s == 1 then return { "valid 2" } end
        return { "" }
    end
    
    local parse_calls = 0
    async_utils.parse_item = function(text, efm)
        parse_calls = parse_calls + 1
        if text == "valid 2" then return { valid = 1, filename = "file.txt", lnum = 10 } end
        return nil
    end

    local jump_item = nil
    async_utils.perform_jump = function(item) jump_item = item end

    -- Start at line 0 (or 1, since direction is 1)
    async_controller.navigate(1)

    assert.are.equal(2, parse_calls)
    assert.truthy(jump_item)
    assert.are.equal(10, jump_item.lnum)
  end)

  it("should notify if no more items found", function()
    local notified = false
    vim.notify = function(msg) notified = true end
    
    async_controller.navigate(1)
    assert.is_true(notified)
  end)
end)
