local M = {}

local color_map = {
  [30] = "Comment",
  [31] = "DiagnosticError",
  [32] = "DiagnosticOk",
  [33] = "DiagnosticWarn",
  [34] = "DiagnosticHint",
  [35] = "Identifier",
  [36] = "Special",
  [37] = "Normal",
}

-- Standard bright versions (90-97)
for i = 30, 37 do
  color_map[i + 60] = color_map[i]
end

function M.strip(str)
  if not str then return str end
  return str:gsub("\27%[[0-9;]*[mK]", "")
end

function M.create_processor(bufnr)
  local ns = vim.api.nvim_create_namespace("async_ansi_" .. bufnr)
  local state = { fg = nil }

  return {
    ns = ns,
    ---@param text string Raw text with ANSI codes
    ---@return string cleaned_text, table highlights
    process_line = function(text)
      local clean_line = ""
      local highlights = {}
      local last_pos = 1
      
      for start_pos, full_match, codes_str, end_pos in text:gmatch("()(\27%[([0-9;]*)[mK])()") do
        local chunk = text:sub(last_pos, start_pos - 1)
        local start_col = #clean_line
        clean_line = clean_line .. chunk
        local end_col = #clean_line
        
        if state.fg and start_col < end_col and color_map[state.fg] then
          table.insert(highlights, { start_col, end_col, color_map[state.fg] })
        end

        if full_match:match("m$") then
          local codes = vim.split(codes_str, ";")
          if #codes == 1 and codes[1] == "" then codes = { "0" } end
          for _, code_s in ipairs(codes) do
            local code = tonumber(code_s) or 0
            if code == 0 then state.fg = nil
            elseif (code >= 30 and code <= 37) or (code >= 90 and code <= 97) then state.fg = code
            elseif code == 39 then state.fg = nil end
          end
        end
        last_pos = end_pos
      end

      local final_chunk = text:sub(last_pos)
      local start_col = #clean_line
      clean_line = clean_line .. final_chunk
      local end_col = #clean_line
      
      if state.fg and start_col < end_col and color_map[state.fg] then
        table.insert(highlights, { start_col, end_col, color_map[state.fg] })
      end

      return clean_line, highlights
    end
  }
end

return M