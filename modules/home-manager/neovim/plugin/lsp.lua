-- LSP Integrations
local function lsp_complete(ArgLead, CmdLine, CursorPos)
  local parts = vim.split(CmdLine:sub(1, CursorPos), "%s+")
  local n = #parts

  if n == 2 then
    local subs = { "references", "definition", "implementation", "type_definition", "declaration" }
    return vim.tbl_filter(function(s)
      return s:match("^" .. ArgLead)
    end, subs)
  end
  return {}
end

vim.api.nvim_create_user_command("Lsp", function(opts)
  local fargs = opts.fargs
  if #fargs == 0 then
    print("Usage: Lsp <references|definition|implementation|type_definition|declaration>")
    return
  end

  local subcommand = fargs[1]
  local lsp = require("async.lsp")
  
  if lsp[subcommand] then
    lsp[subcommand]()
  else
    print("Unknown LSP subcommand: " .. subcommand)
  end
end, { nargs = "+", complete = lsp_complete })
