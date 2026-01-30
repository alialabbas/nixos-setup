local async = require("async")
local M = {}

---Get or create a buffer by name
---@param name string
---@return number
local function get_or_create_buf(name)
  local bufnr = vim.fn.bufnr("^" .. name .. "$")
  if bufnr ~= -1 then
    return bufnr
  end
  local b = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_name(b, name)
  return b
end

---Run git ls-files asynchronously
---@param args? string|string[]
function M.ls_files(args)
  local project = vim.fn.fnamemodify(vim.uv.cwd(), ":t")
  local buf_name = string.format("//git/%s", project)
  local bufnr = get_or_create_buf(buf_name)
  local winid = vim.api.nvim_get_current_win()

  local cmd = { "git" }
  if type(args) == "table" then
    local has_ls = false
    for _, a in ipairs(args) do if a == "ls-files" then has_ls = true break end end
    if not has_ls then table.insert(cmd, "ls-files") end
    for _, a in ipairs(args) do table.insert(cmd, a) end
  else
    table.insert(cmd, "ls-files")
    if type(args) == "string" and args ~= "" then
      for a in string.gmatch(args, "%S+") do table.insert(cmd, a) end
    end
  end

  async.run(cmd, {
        sinks = {
            async.sinks.buffer.new({
                bufnr = bufnr,
                efm = "%f",
                winid = winid,
                auto_open = true,
                clear = true,
                processor = require("async.processors").create_processor,
                processor_opts = {
                    pattern = "^(.*)$"
                }
            }),
            async.sinks.fidget.new()
        }
  })
end

---Proxy function for Git command
---@param opts table
function M.proxy(opts)
  local fargs = opts.fargs

  local is_ls = false
  for _, arg in ipairs(fargs) do
    if arg == "ls-files" then is_ls = true break end
  end

  if is_ls and fargs[1] ~= "help" then
    M.ls_files(fargs)
    return
  end

  -- Use Fugitive's :G command for delegation as it is the most stable entry point
  if vim.fn.exists(":G") == 2 then
    local bang = opts.bang and "!" or ""
    local range = ""
    if opts.range > 0 then
      range = string.format("%d,%d", opts.line1, opts.line2)
    end
    vim.cmd(string.format("%sG%s %s", range, bang, opts.args))
  elseif opts.args ~= "" then
    -- If Fugitive is missing, run as a standard synchronous shell command
    vim.cmd("!git " .. opts.args)
  else
    print("Usage: Git ls-files | <fugitive-command>")
  end
end

---Completion function for Git command
---@param ArgLead string
---@param CmdLine string
---@param CursorPos number
---@return string[]
function M.complete(ArgLead, CmdLine, CursorPos)
  local result = {}
  local seen = {}

  local function add(item, skip_filter)
    if not item or item == "" or seen[item] then return end
    if skip_filter or string.find(item, ArgLead, 1, true) == 1 then
      table.insert(result, item)
      seen[item] = true
    end
  end

  -- 1. Delegate to Fugitive's completion by proxying to 'G'
  local before_cursor = CmdLine:sub(1, CursorPos)
  if string.find(before_cursor, "^%s*Git") then
    local g_cmdline = string.gsub(before_cursor, "Git", "G", 1)
    local g_cursor_pos = #g_cmdline
    local prefix = string.sub(g_cmdline, 1, g_cursor_pos - #ArgLead)

    -- Use getcompletion as it's the most robust API
    local matches = vim.fn.getcompletion(g_cmdline, "cmdline")
    if matches and #matches > 0 then
      for _, m in ipairs(matches) do
        local item = m
        if string.find(m, prefix, 1, true) == 1 then
          item = string.sub(m, #prefix + 1)
        end
        if item ~= "" then add(item, true) end
      end
    end

    -- Fallback to direct function call if getcompletion returned nothing
    if #result == 0 then
      for _, func in ipairs({ "FugitiveComplete", "fugitive#Complete" }) do
        if vim.fn.exists("*" .. func) ~= 0 then
          local ok, f_matches = pcall(vim.fn[func], ArgLead, g_cmdline, g_cursor_pos)
          if ok and type(f_matches) == "table" then
            for _, m in ipairs(f_matches) do add(m, true) end
            break
          end
        end
      end
    end
  end

  -- 2. Add our custom extensions
  local parts = {}
  for p in string.gmatch(before_cursor, "%S+") do
    table.insert(parts, p)
  end
  local has_trailing_space = string.match(before_cursor, "%s$") ~= nil

  -- Subcommand position detection
  local subcommand_pos = false
  if #parts == 1 and has_trailing_space then
    subcommand_pos = true
  elseif #parts == 2 and not has_trailing_space then
    subcommand_pos = true
  else
    local found_sub = false
    for i = 2, #parts - (has_trailing_space and 0 or 1) do
      if not parts[i]:match("^-") then
        found_sub = true
        break
      end
    end
    if not found_sub then subcommand_pos = true end
  end

  if subcommand_pos then
    add("ls-files")
  end

  -- ls-files flags
  local is_ls_files = false
  for _, p in ipairs(parts) do
    if p == "ls-files" then
      is_ls_files = true
      break
    end
  end

  if is_ls_files then
    local is_flag_pos = has_trailing_space or (parts[#parts] and parts[#parts]:match("^-"))
    if is_flag_pos then
      local flags = {
        "-c", "--cached", "-d", "--deleted", "-m", "--modified", "-o", "--others",
        "-i", "--ignored", "-s", "--stage", "-u", "--unmerged", "-k", "--killed",
        "--directory", "--no-empty-directory", "--error-unmatch", "--exclude-standard",
        "--full-name", "--recurse-submodules", "--abbrev", "--debug", "--eol",
      }
      for _, f in ipairs(flags) do
        add(f)
      end
    end
  end

  table.sort(result)
  return result
end

return M
