local M = {}

---@class Async.Highlighter.Opts
---@field pattern? string Regex to extract filename, line, col, and code
---@field ft? string Static filetype
---@field groups? table<string, string> Custom highlight groups

local default_groups = {
  filename = "Directory",
  line = "LineNr",
  col = "Special",
}

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
