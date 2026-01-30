local menu = require('ui.menu')
local M = {}
local last_cmd = ""
---@type string[]
local current_list = {}
local show_timer = vim.uv.new_timer()
local ui = menu.new({
    highlight = 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel',
})

---Show the cmdline completion menu
function M.show()
    local cmd = vim.fn.getcmdline()
    local cmd_type = vim.fn.getcmdtype()

    if cmd_type ~= ':' or #cmd == 0 then
        M.close()
        return
    end

    local is_cycling = false
    for _, item in ipairs(current_list) do
        if cmd:sub(- #item) == item then
            is_cycling = true
            break
        end
    end

    if not is_cycling or #cmd < #last_cmd then
        local results = vim.fn.getcompletion(cmd, 'cmdline')
        if #results == 0 then
            results = vim.fn.getcompletion(cmd .. '*', 'cmdline')
        end

        if #results == 0 then
            M.close()
            return
        end

        current_list = results
        last_cmd = cmd
    end

    local selected_idx = nil
    local max_match_len = -1
    for i, item in ipairs(current_list) do
        if cmd:sub(- #item) == item then
            if #item > max_match_len then
                selected_idx = i
                max_match_len = #item
            end
        end
    end

    local height = math.min(#current_list, ui.config.max_height)
    local row = math.max(0, vim.o.lines - height - 3)

    ui:open(current_list, {
        relative = 'editor',
        row = row,
        col = 2,
    })

    ui:set_cursor(selected_idx)
    vim.cmd('redraw')
end

---Close the cmdline completion menu
function M.close()
    ui:close()
    current_list = {}
    last_cmd = ""
    vim.cmd('redraw')
end

---Initialize cmdline UI
function M.setup()
    vim.opt.wildmenu = false
    vim.opt.wildmode = "longest:full,full"
    vim.opt.wildoptions = ""

    local group = vim.api.nvim_create_augroup('cmdline_ui', { clear = true })

    vim.api.nvim_create_autocmd('CmdlineChanged', {
        group = group,
        callback = function()
            show_timer:stop()
            show_timer:start(20, 0, vim.schedule_wrap(function()
                if vim.fn.getcmdtype() == ':' then
                    M.show()
                end
            end))
        end
    })

    vim.api.nvim_create_autocmd('CmdlineLeave', {
        group = group,
        callback = function()
            show_timer:stop()
            M.close()
        end
    })
end

M.setup()

return M