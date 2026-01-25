local async = require("async")
local M = {}

local function get_or_create_buf(name)
  local bufnr = vim.fn.bufnr("^" .. name .. "$")
  if bufnr ~= -1 then
    return bufnr
  end
  local b = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_name(b, name)
  return b
end

---@param method string LSP method (e.g. 'textDocument/references')
function M.request(method)
  local method_short = method:match("/([^/]+)$") or method
  local project = vim.fn.fnamemodify(vim.uv.cwd(), ":t")
  local buf_name = string.format("//lsp/%s", project)
  local bufnr = get_or_create_buf(buf_name)
  local winid = vim.api.nvim_get_current_win()
  
  local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
  local clients = get_clients({ bufnr = 0, method = method })
  
  if #clients == 0 then
    vim.notify("No LSP clients support " .. method, vim.log.levels.WARN)
    return
  end

  -- Use the first client's encoding for position params to avoid diagnostic warning
  local params = vim.lsp.util.make_position_params(0, clients[1].offset_encoding)
  if method == "textDocument/references" then
    params.context = { includeDeclaration = true }
  end

  async.run(function(emit, task)
    local responses = 0
    local expected = 0
    local all_items = {}

    local function finalize()
      if #all_items == 0 then
        emit("No results found for " .. method_short)
      elseif #all_items == 1 then
        local item = all_items[1]
        vim.schedule(function()
          if winid and vim.api.nvim_win_is_valid(winid) then
            local b = vim.fn.bufadd(item.filename)
            vim.api.nvim_win_set_buf(winid, b)
            vim.api.nvim_win_set_cursor(winid, { item.lnum, math.max(0, item.col - 1) })
            vim.api.nvim_set_current_win(winid)
            vim.cmd("normal! zz")
          end
          task.complete()
        end)
      else
        table.sort(all_items, function(a, b)
          if a.filename ~= b.filename then return a.filename < b.filename end
          return a.lnum < b.lnum
        end)

        for _, item in ipairs(all_items) do
          local clean_text = item.text:match("^%s*(.-)%s*$") or ""
          local line = string.format("%s:%d:%d: %s", item.filename, item.lnum, item.col, clean_text)
          emit(line)
        end
      end
      task.complete()
    end

    local function check_done()
      responses = responses + 1
      if responses == expected then
        finalize()
      end
    end

    for _, client in ipairs(clients) do
      -- Use client:request instead of client.request to avoid deprecation warning
      local ok, _ = client:request(method, params, function(err, result)
        if err then
          emit(string.format("[%s Error]: %s", client.name, err.message))
        elseif result then
          local items = vim.lsp.util.locations_to_items(result, client.offset_encoding or "utf-16")
          vim.list_extend(all_items, items)
        end
        check_done()
      end, 0)
      
      if ok then
        expected = expected + 1
      end
    end

    if expected == 0 then
      emit("Failed to request " .. method .. " from any client")
      task.complete()
    end
  end, {
    sinks = {
      async.sinks.buffer.new({
        bufnr = bufnr,
        efm = "%f:%l:%c: %m",
        winid = winid,
        auto_open = #vim.api.nvim_list_uis() > 0,
        clear = true,
        processor = require("async.highlighter").create_processor,
      }),
      async.sinks.fidget.new(),
    }
  })
end

function M.references() M.request("textDocument/references") end
function M.definition() M.request("textDocument/definition") end
function M.implementation() M.request("textDocument/implementation") end
function M.type_definition() M.request("textDocument/typeDefinition") end
function M.declaration() M.request("textDocument/declaration") end

return M
