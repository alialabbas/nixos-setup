local menu = require('ui.menu')
local ui = menu.new({
    highlight = 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel',
})

local M = {}
---@type any[]
local current_items = {}
local selected_idx = 0
local show_timer = vim.uv.new_timer()
local doc_timer = vim.uv.new_timer()
local doc_win_id = nil
local doc_buf_id = nil
local sig_win_id = nil
local sig_buf_id = nil

-- Define highlight groups for Kinds
local kind_colors = {
    Method = "Function",
    Function = "Function",
    Constructor = "Type",
    Field = "Identifier",
    Variable = "Identifier",
    Class = "Type",
    Interface = "Type",
    Module = "Include",
    Property = "Identifier",
    Unit = "Constant",
    Value = "Constant",
    Enum = "Type",
    Keyword = "Keyword",
    Snippet = "Special",
    Color = "Special",
    File = "Directory",
    Reference = "Special",
    Folder = "Directory",
    EnumMember = "Constant",
    Constant = "Constant",
    Struct = "Type",
    Event = "Special",
    Operator = "Operator",
    TypeParameter = "Type",
}

local kind_icons = {
    Text = "󰉿",
    Method = "󰆧",
    Function = "󰊕",
    Constructor = "",
    Field = "󰜢",
    Variable = "󰀫",
    Class = "󰠱",
    Interface = "󰅩",
    Module = "",
    Property = "󰜢",
    Unit = "󰑭",
    Value = "󰎟",
    Enum = "󰦨",
    Keyword = "󰌋",
    Snippet = "",
    Color = "󰏘",
    File = "󰈚",
    Reference = "󰈇",
    Folder = "󰉋",
    EnumMember = "󰒻",
    Constant = "󰏿",
    Struct = "󰙅",
    Event = "󰉁",
    Operator = "󰆕",
    TypeParameter = "󰅲",
}

local kind_map = vim.lsp.protocol.CompletionItemKind
local kind_names = {}
for name, id in pairs(kind_map) do kind_names[id] = name end

---Get icon for completion item
---@param item table
---@return string
local function get_icon(item)
    local kind_name = kind_names[item.kind]
    return kind_icons[kind_name] or "󰉿"
end

---Close documentation window
function M.close_docs()
    if doc_win_id and vim.api.nvim_win_is_valid(doc_win_id) then
        pcall(vim.api.nvim_win_close, doc_win_id, true)
    end
    doc_win_id = nil
end

---Close signature window
function M.close_sig()
    if sig_win_id and vim.api.nvim_win_is_valid(sig_win_id) then
        pcall(vim.api.nvim_win_close, sig_win_id, true)
    end
    sig_win_id = nil
end

---Scroll documentation window
---@param delta number
function M.scroll_docs(delta)
    if doc_win_id and vim.api.nvim_win_is_valid(doc_win_id) then
        pcall(vim.api.nvim_win_call, doc_win_id, function()
            local top = vim.fn.line('w0')
            local last = vim.fn.line('$')
            local height = vim.api.nvim_win_get_height(0)
            local new_top = math.max(1, math.min(top + delta, last - height + 1))
            vim.cmd('normal! ' .. new_top .. 'zt')
        end)
    end
end

---Render documentation content
---@param docs string|table
function M.render_docs(docs)
    if not docs then return end
    if not doc_buf_id or not vim.api.nvim_buf_is_valid(doc_buf_id) then
        doc_buf_id = vim.api.nvim_create_buf(false, true)
    end

    local lines = vim.lsp.util.convert_input_to_markdown_lines(docs)
    lines = vim.lsp.util.trim_empty_lines(lines)
    if #lines == 0 then return end

    vim.api.nvim_buf_set_lines(doc_buf_id, 0, -1, false, lines)
    vim.api.nvim_set_option_value('filetype', 'markdown', { buf = doc_buf_id })

    if not ui.win_id or not vim.api.nvim_win_is_valid(ui.win_id) then return end
    
    local ui_width = vim.api.nvim_win_get_width(ui.win_id)
    local ui_height = vim.api.nvim_win_get_height(ui.win_id)
    local ui_pos = vim.api.nvim_win_get_position(ui.win_id)
    
    local width = math.min(80, vim.o.columns - ui_pos[2] - ui_width - 3)
    local height = math.min(20, #lines)
    
    local col = ui_pos[2] + ui_width + 2
    if width < 30 then
        width = math.min(80, ui_pos[2] - 3)
        if width < 30 then return end
        col = ui_pos[2] - width - 2
    end

    doc_win_id = vim.api.nvim_open_win(doc_buf_id, false, {
        relative = 'editor',
        row = ui_pos[1],
        col = col,
        width = width,
        height = height,
        border = 'rounded',
        style = 'minimal',
    })
    vim.api.nvim_set_option_value('winhl', 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder', { win = doc_win_id })
end

---Resolve completion item and show documentation
---@param item table
function M.resolve_and_show_docs(item)
    doc_timer:stop()
    doc_timer:start(50, 0, vim.schedule_wrap(function()
        M.close_docs()
        if not item then return end
        if item.documentation then return M.render_docs(item.documentation) end

        local client = vim.lsp.get_client_by_id(item.client_id)
        if client and client.server_capabilities.completionProvider and client.server_capabilities.completionProvider.resolveProvider then
            client.request('completionItem/resolve', item, function(err, result)
                if not err and result and result.documentation then
                    item.documentation = result.documentation
                    if current_items[selected_idx] and current_items[selected_idx].label == item.label then
                        M.render_docs(result.documentation)
                    end
                end
            end)
        end
    end))
end

---Show signature help
function M.signature_help()
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(0, 'textDocument/signatureHelp', params, function(err, result)
        if err or not result or not result.signatures or #result.signatures == 0 then
            M.close_sig()
            return
        end

        if not sig_buf_id or not vim.api.nvim_buf_is_valid(sig_buf_id) then
            sig_buf_id = vim.api.nvim_create_buf(false, true)
        end

        local sig = result.signatures[result.activeSignature + 1] or result.signatures[1]
        local label = sig.label
        vim.api.nvim_buf_set_lines(sig_buf_id, 0, -1, false, { label })
        
        vim.api.nvim_buf_clear_namespace(sig_buf_id, -1, 0, -1)
        if sig.parameters and #sig.parameters > 0 then
            local active_param_idx = result.activeParameter or sig.activeParameter or 0
            local param = sig.parameters[active_param_idx + 1]
            if param then
                local s, e
                if type(param.label) == "table" then
                    s, e = param.label[1], param.label[2]
                else
                    s, e = label:find(param.label, 1, true)
                    if s then s = s - 1 end
                end
                if s and e then
                    vim.api.nvim_buf_add_highlight(sig_buf_id, -1, "LspSignatureActiveParameter", 0, s, e)
                end
            end
        end

        if not sig_win_id or not vim.api.nvim_win_is_valid(sig_win_id) then
            sig_win_id = vim.api.nvim_open_win(sig_buf_id, false, {
                relative = 'cursor',
                row = -1,
                col = 0,
                width = #label,
                height = 1,
                style = 'minimal',
                border = 'rounded',
                focusable = false,
                zindex = 300,
            })
            vim.api.nvim_set_option_value('winhl', 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder', { win = sig_win_id })
        else
            vim.api.nvim_win_set_config(sig_win_id, { width = #label })
        end
    end)
end

---Close completion menu and documentation
function M.close()
    ui:close()
    M.close_docs()
    current_items = {}
    selected_idx = 0
end

---Confirm completion selection
function M.confirm()
    local item = current_items[selected_idx]
    if not item then
        M.close()
        return
    end

    local ok, err = pcall(function()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local line = vim.api.nvim_get_current_line()
        local line_len = #line
        
        local start_col, end_col
        if item.textEdit then
            local range = item.textEdit.range or item.textEdit.insert or item.textEdit.replace
            if range then
                start_col = range.start.character
                end_col = range["end"].character
            end
        end

        if not start_col or not end_col then
            local word = line:sub(1, cursor[2]):match("[%w_]+$") or ""
            start_col = cursor[2] - #word
            end_col = cursor[2]
        end

        start_col = math.max(0, math.min(start_col, line_len))
        end_col = math.max(0, math.min(end_col, line_len))
        if start_col > end_col then start_col = end_col end

        local insert_text = (item.textEdit and item.textEdit.newText) or item.insertText or item.label
        local is_snippet = item.insertTextFormat == 2 or item.kind == 15
        local edits = item.additionalTextEdits
        local client_id = item.client_id

        M.close()

        vim.api.nvim_buf_set_text(0, cursor[1]-1, start_col, cursor[1]-1, end_col, { "" })
        vim.api.nvim_win_set_cursor(0, { cursor[1], start_col })

        vim.schedule(function()
            if is_snippet then
                vim.snippet.expand(insert_text)
            else
                vim.api.nvim_put({ insert_text }, 'c', false, true)
            end

            if edits and client_id then
                local client = vim.lsp.get_client_by_id(client_id)
                if client then
                    vim.lsp.util.apply_text_edits(edits, vim.api.nvim_get_current_buf(), client.offset_encoding)
                end
            end
        end)
    end)

    if not ok then
        vim.notify("Completion failed: " .. tostring(err), vim.log.levels.ERROR)
        M.close()
    end
end

---Trigger completion request
function M.trigger()
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(0, 'textDocument/completion', params, function(err, result, ctx)
        if err or not result then return end
        local items = result.items or result
        if #items == 0 then M.close() return end

        local cursor = vim.api.nvim_win_get_cursor(0)
        local line = vim.api.nvim_get_current_line()
        local word = line:sub(1, cursor[2]):match("[%w_]+$") or ""
        
        local filtered = {}
        for _, item in ipairs(items) do
            if item.label:lower():find(word:lower(), 1, true) then
                item.client_id = ctx.client_id
                table.insert(filtered, item)
            end
        end

        if #filtered == 0 then M.close() return end

        table.sort(filtered, function(a, b)
            -- Respect server preselect
            if a.preselect and not b.preselect then return true end
            if b.preselect and not a.preselect then return false end
            
            local sa = a.sortText or a.label
            local sb = b.sortText or b.label
            if sa ~= sb then return sa < sb end
            return a.label < b.label
        end)

        current_items = filtered
        selected_idx = 1
        
        local menu_items = {}
        local max_label = 0
        for _, item in ipairs(filtered) do max_label = math.max(max_label, #item.label) end

        for _, item in ipairs(filtered) do
            local icon = get_icon(item)
            local kind_name = kind_names[item.kind] or ""
            local detail = (item.detail or ""):gsub("%s+", " "):sub(1, 40)
            
            local line_text = string.format(" %-" .. max_label .. "s  %s %-10s │ %s", 
                item.label, icon, kind_name, detail)
            
            local icon_start = 1 + max_label + 2
            local icon_end = icon_start + #icon
            
            local hls = {
                { group = kind_colors[kind_name] or "Special", start_col = icon_start, end_col = icon_end },
                { group = "Comment", start_col = icon_end + 11, end_col = -1 }
            }
            
            -- Add match highlighting
            local match_start, match_end = item.label:lower():find(word:lower(), 1, true)
            if match_start then
                table.insert(hls, { group = "CmpItemAbbrMatch", start_col = match_start, end_col = match_end + 1 })
            end
            
            table.insert(menu_items, { text = line_text, highlights = hls })
        end

        ui:open(menu_items, { relative = 'cursor', row = 1, col = 0 })
        ui:set_cursor(selected_idx)
        M.resolve_and_show_docs(filtered[selected_idx])
    end)
end

---Initialize completion setup
function M.setup()
    local group = vim.api.nvim_create_augroup('custom_completion', { clear = true })

    vim.api.nvim_create_autocmd({ 'TextChangedI', 'TextChangedP' }, {
        group = group,
        callback = function()
            local line = vim.api.nvim_get_current_line()
            local cursor = vim.api.nvim_win_get_cursor(0)
            local char_before = line:sub(cursor[2], cursor[2])
            
            if char_before == '(' or char_before == ',' then
                M.signature_help()
            elseif char_before:match("[%w_%.]") then
                show_timer:stop()
                show_timer:start(10, 0, vim.schedule_wrap(M.trigger))
            else
                if ui.win_id then M.close() end
                if sig_win_id then M.close_sig() end
            end
        end
    })

    vim.api.nvim_create_autocmd('CursorMovedI', {
        group = group,
        callback = function()
            if ui.win_id then
                local line = vim.api.nvim_get_current_line()
                local cursor = vim.api.nvim_win_get_cursor(0)
                if not line:sub(1, cursor[2]):match("[%w_]+$") then M.close() end
            end
            -- Signature help check
            if sig_win_id then
                local line = vim.api.nvim_get_current_line()
                local cursor = vim.api.nvim_win_get_cursor(0)
                local char_before = line:sub(cursor[2], cursor[2])
                if not char_before:match("[%w_%.%(%,]") then M.close_sig() end
            end
        end
    })

    vim.api.nvim_create_autocmd({ 'InsertLeave', 'BufLeave' }, {
        group = group,
        callback = function()
            M.close()
            M.close_sig()
        end
    })

    -- KEYMAPS
    vim.keymap.set('i', '<Tab>', function()
        if ui.win_id then
            selected_idx = (selected_idx % #current_items) + 1
            ui:set_cursor(selected_idx)
            M.resolve_and_show_docs(current_items[selected_idx])
        elseif vim.snippet.active({ direction = 1 }) then
            vim.snippet.jump(1)
        else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
        end
    end)

    vim.keymap.set('i', '<S-Tab>', function()
        if ui.win_id then
            selected_idx = selected_idx - 1
            if selected_idx < 1 then selected_idx = #current_items end
            ui:set_cursor(selected_idx)
            M.resolve_and_show_docs(current_items[selected_idx])
        elseif vim.snippet.active({ direction = -1 }) then
            vim.snippet.jump(-1)
        else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<S-Tab>', true, false, true), 'n', false)
        end
    end)

    vim.keymap.set('i', '<CR>', function()
        if ui.win_id and selected_idx > 0 then
            M.confirm()
        else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
        end
    end)

    vim.keymap.set('i', '<C-Space>', M.trigger)
    vim.keymap.set('i', '<C-d>', function() M.scroll_docs(4) end)
    vim.keymap.set('i', '<C-u>', function() M.scroll_docs(-4) end)
end

M.setup()

return M
