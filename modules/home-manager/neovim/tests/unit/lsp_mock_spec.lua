local async = require("async")
local lsp = require("async.lsp")

describe("LSP Integration (Simplified)", function()
  local old_get_clients = vim.lsp.get_clients
  local old_get_active_clients = vim.lsp.get_active_clients
  local old_locations_to_items = vim.lsp.util.locations_to_items
  local old_make_params = vim.lsp.util.make_position_params
  local old_notify = vim.notify

  before_each(function()
    vim.notify = function() end
    vim.lsp.util.locations_to_items = function(result, encoding)
      if type(result) == "table" and result.is_mock then
        return result.items
      end
      return old_locations_to_items(result, encoding)
    end
    -- Mock make_position_params to avoid window/buffer dependency
    vim.lsp.util.make_position_params = function(winid, offset_encoding)
      return { textDocument = { uri = "file:///test.lua" }, position = { line = 0, character = 0 } }
    end
  end)

  after_each(function()
    vim.lsp.get_clients = old_get_clients
    vim.lsp.get_active_clients = old_get_active_clients
    vim.lsp.util.locations_to_items = old_locations_to_items
    vim.lsp.util.make_position_params = old_make_params
    vim.notify = old_notify
  end)

  it("should stream LSP results to a buffer", function()
    local method = "textDocument/references"
    local mock_items = {
      { filename = "file1.lua", lnum = 10, col = 5, text = "ref1" },
      { filename = "file2.lua", lnum = 20, col = 1, text = "ref2" },
    }

    local client_mock = {
      name = "mock_client",
      offset_encoding = "utf-16",
      request = function(self, m, params, cb, bufnr)
        vim.schedule(function()
          cb(nil, { is_mock = true, items = mock_items })
        end)
        return true
      end
    }

    vim.lsp.get_clients = function() return { client_mock } end

    lsp.request(method)

    -- Wait for task to finish
    vim.wait(2000, function() return #async.list() == 0 end)

    local project = vim.fn.fnamemodify(vim.uv.cwd(), ":t")
    local buf_name = "//lsp/" .. project
    local bufnr = vim.fn.bufnr("^" .. buf_name .. "$")
    assert.truthy(bufnr ~= -1)

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local content = table.concat(lines, "\n")
    
    assert.truthy(content:match("file1.lua:10:5: ref1"))
    assert.truthy(content:match("file2.lua:20:1: ref2"))
  end)

  it("should handle LSP errors", function()
    local method = "textDocument/definition"
    local client_mock = {
      name = "error_client",
      request = function(self, m, params, cb, bufnr)
        vim.schedule(function()
          cb({ message = "Something went wrong" })
        end)
        return true
      end
    }

    vim.lsp.get_clients = function() return { client_mock } end

    lsp.request(method)

    vim.wait(2000, function() return #async.list() == 0 end)

    local project = vim.fn.fnamemodify(vim.uv.cwd(), ":t")
    local buf_name = "//lsp/" .. project
    local bufnr = vim.fn.bufnr("^" .. buf_name .. "$")
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local content = table.concat(lines, "\n")

    assert.truthy(content:match("%[error_client Error%]: Something went wrong"))
  end)

  it("should jump directly to a single LSP result", function()
    local method = "textDocument/definition"
    local mock_items = {
      { filename = "single_file.lua", lnum = 5, col = 1, text = "single ref" },
    }

    local client_mock = {
      name = "single_client",
      offset_encoding = "utf-16",
      request = function(self, m, params, cb, bufnr)
        vim.schedule(function()
          cb(nil, { is_mock = true, items = mock_items })
        end)
        return true
      end
    }

    vim.lsp.get_clients = function() return { client_mock } end

    -- We need to mock nvim_win_set_buf and nvim_win_set_cursor to verify the jump
    local old_set_buf = vim.api.nvim_win_set_buf
    local old_set_cursor = vim.api.nvim_win_set_cursor
    local old_win_valid = vim.api.nvim_win_is_valid
    local target_buf
    local cursor_calls = {}

    vim.api.nvim_win_set_buf = function(win, buf) target_buf = buf end
    vim.api.nvim_win_set_cursor = function(win, cur) 
      table.insert(cursor_calls, cur)
    end
    vim.api.nvim_win_is_valid = function(win) return true end

    lsp.request(method)

    vim.wait(2000, function() return #cursor_calls > 0 end)

    assert.truthy(target_buf)
    -- Check if any of the calls was to line 5
    local found_5 = false
    for _, c in ipairs(cursor_calls) do
      if c[1] == 5 then found_5 = true end
    end
    assert.is_true(found_5)

    -- Restore
    vim.api.nvim_win_set_buf = old_set_buf
    vim.api.nvim_win_set_cursor = old_set_cursor
    vim.api.nvim_win_is_valid = old_win_valid
  end)
end)
