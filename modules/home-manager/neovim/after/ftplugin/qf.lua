-- after/ftplugin/qf.lua

-- 1. Delete items with 'dd'
vim.keymap.set("n", "dd", function()
    local qf = vim.fn.getqflist()
    local curline = vim.fn.line(".")
    if #qf == 0 then return end
    
    table.remove(qf, curline)
    vim.fn.setqflist(qf, 'r')
    
    -- Maintain cursor position as best as possible
    local new_line = math.min(curline, #qf)
    if new_line > 0 then
        vim.api.nvim_win_set_cursor(0, { new_line, 0 })
    end
end, { buffer = true, desc = "Remove item from quickfix" })

-- Persistent state for the floating window
local preview_win = nil

local function close_preview()
    if preview_win and vim.api.nvim_win_is_valid(preview_win) then
        vim.api.nvim_win_close(preview_win, true)
    end
    preview_win = nil
end

-- 2. Floating Preview Logic
local function preview_qf_item()
    local qf = vim.fn.getqflist()
    local item = qf[vim.fn.line(".")]
    if not (item and item.bufnr ~= 0) then return end
    
    -- Ensure the buffer is loaded (handles swap files silently)
    if not vim.api.nvim_buf_is_loaded(item.bufnr) then
        local group = vim.api.nvim_create_augroup("QFPreviewSwap", { clear = true })
        vim.api.nvim_create_autocmd("SwapExists", {
            group = group,
            callback = function() vim.v.swapchoice = 'o' end,
        })
        pcall(vim.fn.bufload, item.bufnr)
        vim.api.nvim_del_augroup_by_id(group)
    end

    -- Create floating window if it doesn't exist
    if not (preview_win and vim.api.nvim_win_is_valid(preview_win)) then
        local width = math.floor(vim.o.columns * 0.8)
        local height = math.floor(vim.o.lines * 0.5)
        local row = math.floor((vim.o.lines - height) / 2)
        local col = math.floor((vim.o.columns - width) / 2)

        preview_win = vim.api.nvim_open_win(item.bufnr, false, {
            relative = "editor",
            width = width,
            height = height,
            row = row,
            col = col,
            border = "rounded",
            style = "minimal",
        })
    end

    if preview_win then
        -- Only switch buffer if necessary
        local current_buf = vim.api.nvim_win_get_buf(preview_win)
        if current_buf ~= item.bufnr then
            vim.api.nvim_win_set_buf(preview_win, item.bufnr)
        end

        -- Re-apply UI settings and force syntax validation
        vim.api.nvim_win_call(preview_win, function()
            vim.wo.number = true
            vim.wo.relativenumber = false
            vim.wo.signcolumn = "no"
            vim.wo.statuscolumn = ""
            vim.wo.statusline = ""
            vim.wo.winbar = ""
            vim.wo.foldcolumn = "0"
            vim.wo.colorcolumn = ""
            vim.wo.cursorline = true
            vim.wo.spell = false
            vim.wo.list = false

            -- Force filetype detection if missing
            if vim.bo.filetype == "" then
                vim.cmd("filetype detect")
            end
            
            -- Ensure syntax is on (kicks treesitter if it's being lazy)
            if vim.api.nvim_get_option_value("syntax", { scope = "local" }) == "" then
                vim.cmd("syntax on")
            end
            
            -- Center the line and force a redraw
            vim.cmd("normal! zz")
        end)

        local line_count = vim.api.nvim_buf_line_count(item.bufnr)
        local target_line = math.max(1, math.min(item.lnum, line_count))
        vim.api.nvim_win_set_cursor(preview_win, { target_line, 0 })
    end
end

-- 3. Toggle with 'P'
vim.keymap.set("n", "P", function()
    if preview_win and vim.api.nvim_win_is_valid(preview_win) then
        close_preview()
    else
        preview_qf_item()
    end
end, { buffer = true, desc = "Toggle floating preview" })

-- 4. Close with 'q'
vim.keymap.set("n", "q", function()
    close_preview()
    vim.cmd("cclose")
end, { buffer = true, desc = "Close quickfix and preview" })

-- 5. Auto-update and Cleanup
vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = 0,
    callback = function()
        if preview_win and vim.api.nvim_win_is_valid(preview_win) then
            preview_qf_item()
        end
    end,
})

-- Close preview if we switch away from the quickfix list
vim.api.nvim_create_autocmd("BufLeave", {
    buffer = 0,
    callback = close_preview,
})

-- 6. Smart Open with <CR>
vim.keymap.set("n", "<CR>", function()
    local qf = vim.fn.getqflist()
    local item = qf[vim.fn.line(".")]
    if not (item and item.bufnr ~= 0) then return end

    local target_win = nil
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if not vim.wo[win].previewwindow and vim.bo[buf].filetype ~= "qf" then
            target_win = win
            break
        end
    end

    if target_win then
        vim.api.nvim_win_set_buf(target_win, item.bufnr)
        vim.api.nvim_win_set_cursor(target_win, { item.lnum, 0 })
        vim.api.nvim_set_current_win(target_win)
    else
        vim.cmd("vsplit")
        local new_win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(new_win, item.bufnr)
        vim.api.nvim_win_set_cursor(new_win, { item.lnum, 0 })
    end
    
    close_preview()
end, { buffer = true, desc = "Open item in non-qf window" })