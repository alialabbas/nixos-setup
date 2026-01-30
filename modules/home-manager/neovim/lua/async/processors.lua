local M = {}

---@class Async.Processor.Opts
---@field pattern? string Regex to extract filename, line, col, and code
---@field ft? string Static filetype
---@field groups? table<string, string> Custom highlight groups
---@field efm? string Error format
---@field qf_only? boolean Only show valid quickfix items
---@field processor_opts? table

local default_groups = {
  filename = "Directory",
  line = "LineNr",
  col = "Special",
}

---Get treesitter highlights for a string
---@param text string
---@param lang string
---@return table[]
local function get_ts_highlights(text, lang)
  if not lang or lang == "" then return {} end
  local has_ts, ts = pcall(require, "vim.treesitter")
  if not has_ts then return {} end

  local ok_parser, parser = pcall(ts.get_string_parser, text, lang)
  if not ok_parser or not parser then return {} end

  local ok_tree, tree = pcall(parser.parse, parser)
  if not (ok_tree and tree and tree[1]) then return {} end

  local ok_query, query = pcall(ts.query.get, lang, "highlights")
  if not (ok_query and query) then return {} end

  local highlights = {}
  for id, node in query:iter_captures(tree[1]:root(), text, 0, -1) do
    local name = query.captures[id]
    local _, start_col, _, end_col = node:range()
    -- Map TS capture to Neovim highlight group
    local hl_group = "@" .. name .. "." .. lang
    table.insert(highlights, { start_col, end_col, hl_group })
  end
  return highlights
end

---Create a quickfix-based processor
---@param bufnr number
---@param opts? Async.Processor.Opts
---@return Async.AnsiProcessor
function M.create_qf_processor(bufnr, opts)
    opts = opts or {}
    local ns = vim.api.nvim_create_namespace("async_qf_" .. bufnr)
    local efm = opts.efm or vim.bo.errorformat
    local hls = vim.tbl_extend("force", default_groups, opts.groups or {})

    -- Generic state to track location across lines
    local state = { fname = nil, lnum = 0, col = 0 }

    return {
        ns = ns,
        process_line = function(text)
            local qf = vim.fn.getqflist({ lines = { text }, efm = efm })
            local item = qf.items[1]

            if not item or item.valid == 0 then
                return nil
            end

            local fname = vim.fn.bufname(item.bufnr)
            if fname == "" and item.filename ~= "" then fname = item.filename end

            -- Update state if this line provides new location info
            if fname ~= "" then state.fname = fname end
            if item.lnum > 0 then state.lnum = item.lnum end
            if item.col > 0 then state.col = item.col end

            -- Logic: If the line has no message text, it's just a location pointer.
            -- We skip it but keep the location in state for the next line.
            local message = item.text or ""
            local clean_msg = message:match("^%s*(.-)%s*$") or ""
            if clean_msg == "" then
                return nil
            end

            -- Use current item info, fallback to state
            local target_f = (fname ~= "" and fname) or state.fname
            local target_l = (item.lnum > 0 and item.lnum) or state.lnum
            local target_c = (item.col > 0 and item.col) or state.col

            if not target_f then
                return nil
            end

            -- Construct the compact line: no injected labels, just raw parsed text
            local new_text = string.format("%s:%d:%d: %s", target_f, target_l, target_c, message)
            local highlights = {}

            -- Apply standard highlights to the new_text
            local f_end = #target_f
            table.insert(highlights, { 0, f_end, hls.filename })

            local l_str = tostring(target_l)
            local l_start = f_end + 1
            local l_end = l_start + #l_str
            table.insert(highlights, { l_start, l_end, hls.line })

            local c_str = tostring(target_c)
            local c_start = l_end + 1
            local c_end = c_start + #c_str
            table.insert(highlights, { c_start, c_end, hls.col })

            return new_text, highlights
        end
    }
end

---Create a pattern-based processor
---@param bufnr number
---@param opts? Async.Processor.Opts
---@return Async.AnsiProcessor
function M.create_processor(bufnr, opts)
    opts = opts or {}
    local ns = vim.api.nvim_create_namespace("async_hl_" .. bufnr)
    local pattern = opts.pattern or "^(.-):(%d+):(%d+):(.*)$"
    local hls = vim.tbl_extend("force", default_groups, opts.groups or {})
  return {
    ns = ns,
    process_line = function(text)
      local highlights = {}
      local captures = { text:match(pattern) }

      if #captures == 0 then
        return text, highlights
      end

      local f = captures[1]
      local l = captures[2]
      local c = captures[3]
      local code = captures[4]

      -- Filename highlight
      local f_start = text:find(f, 1, true)
      if f_start then
        f_start = f_start - 1
        local f_end = f_start + #f
        table.insert(highlights, { f_start, f_end, hls.filename })

        -- Line highlight
        if l then
          local l_start = text:find(l, f_end, true)
          if l_start then
            l_start = l_start - 1
            local l_end = l_start + #l
            table.insert(highlights, { l_start, l_end, hls.line })

            -- Column highlight
            if c then
              local c_start = text:find(c, l_end, true)
              if c_start then
                c_start = c_start - 1
                local c_end = c_start + #c
                table.insert(highlights, { c_start, c_end, hls.col })

                -- Code/Treesitter highlight
                if code then
                  local code_start = text:find(code, c_end, true)
                  if code_start then
                    code_start = code_start - 1
                    local ft = opts.ft or vim.filetype.match({ filename = f })

                    if ft then
                      local ts_hls = get_ts_highlights(code, ft)
                      for _, hl in ipairs(ts_hls) do
                        table.insert(highlights, { code_start + hl[1], code_start + hl[2], hl[3] })
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end

      return text, highlights
    end
  }
end

return M
