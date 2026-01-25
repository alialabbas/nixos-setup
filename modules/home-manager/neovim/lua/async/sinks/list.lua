local ansi = require("async.ansi")
local utils = require("async.utils")
local M = {}

---@class Async.Sink.ListOpts
---@field type "quickfix"|"loclist"
---@field efm? string
---@field title? string
---@field winnr? number For loclist
---@field text_func? string|function

function M.new(opts)
  opts = opts or {}
  local is_loc = opts.type == "loclist"
  local winid = opts.winnr
  local opened = false

  local function open_list()
    if opened then return end
    opened = true
    local current_win = vim.api.nvim_get_current_win()
    if is_loc then
      if winid and vim.api.nvim_win_is_valid(winid) then
        vim.api.nvim_set_current_win(winid)
        vim.cmd("lopen")
      end
    else
      vim.cmd("botright copen")
    end
    if vim.api.nvim_win_is_valid(current_win) then
      vim.api.nvim_set_current_win(current_win)
    end
  end

  local buffer = utils.line_buffered(function(lines, is_exit, _)
    if #lines > 0 then
      if is_loc then
        if winid and vim.api.nvim_win_is_valid(winid) then
          vim.fn.setloclist(winid, {}, "a", { lines = lines, efm = opts.efm })
          open_list()
        end
      else
        vim.fn.setqflist({}, "a", { lines = lines, efm = opts.efm })
        open_list()
      end
    elseif is_exit then
      open_list()
    end
  end)

  return {
    on_start = function(task)
      if is_loc and not winid then
        winid = vim.api.nvim_get_current_win()
      end
      local title = opts.title or ("Task: " .. table.concat(task.cmd, " "))
      local list_opts = { title = title, lines = {} }
      if opts.text_func then list_opts.quickfixtextfunc = opts.text_func end

      if is_loc then
        if winid and vim.api.nvim_win_is_valid(winid) then
          vim.fn.setloclist(winid, {}, " ", list_opts)
        end
      else
        vim.fn.setqflist({}, " ", list_opts)
      end
    end,
    on_stdout = function(_, data) buffer(ansi.strip(data), false) end,
    on_stderr = function(_, data) buffer(ansi.strip(data), false) end,
    on_exit = function(_, obj) buffer(obj, true) end,
  }
end

return M