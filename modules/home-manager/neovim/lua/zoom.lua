-- Generic Window Zoom Utility
-- Allows maximizing the current window (saving the layout) and restoring it later.
-- Works per-tabpage.

local layout_stack = {}

-- Recursive function to capture the current layout tree
local function get_layout_node(layout)
    if layout[1] == "leaf" then
        return { type = "leaf", winid = layout[2], bufnr = vim.fn.winbufnr(layout[2]) }
    else
        local children = {}
        for _, child in ipairs(layout[2]) do
            table.insert(children, get_layout_node(child))
        end
        return { type = layout[1], children = children }
    end
end

-- Recursive function to re-apply the layout tree
local function apply_layout(layout)
    if layout.type == "leaf" then
        -- Create a split if we aren't at the root, but logic handled by parent loop
        -- Here we just set the buffer
        if vim.fn.bufexists(layout.bufnr) == 1 then 
            vim.cmd("b " .. layout.bufnr) 
        end
    else
        -- Determine split direction based on parent type
        local split_cmd = (layout.type == "col") and "split" or "vsplit"
        
        -- We have one window currently (the one passed from parent or root).
        -- We need to split it N-1 times for N children.
        local wins = { vim.fn.win_getid() }
        
        for i = 2, #layout.children do
            vim.cmd(split_cmd)
            table.insert(wins, vim.fn.win_getid())
        end
        
        -- Now recurse into each child window
        for i, win in ipairs(wins) do
            vim.fn.win_gotoid(win)
            apply_layout(layout.children[i])
        end
    end
end

vim.api.nvim_create_user_command("ZoomToggle", function()
    local tab = vim.api.nvim_get_current_tabpage()
    
    if layout_stack[tab] then
        -- Restore
        -- 1. Wipe current view to a clean slate (single window)
        vim.cmd("only")
        
        -- 2. Re-build the split tree and populate buffers
        apply_layout(layout_stack[tab].tree)
        
        -- 3. Restore window sizes
        vim.cmd(layout_stack[tab].resize)
        
        -- 4. Clear stack
        layout_stack[tab] = nil
    else
        -- Maximize (Save -> Only)
        layout_stack[tab] = {
            tree = get_layout_node(vim.fn.winlayout()),
            resize = vim.fn.winrestcmd()
        }
        vim.cmd("only")
    end
end, {})

-- Keymap: <C-w>z to Zoom/Restore
vim.keymap.set("n", "<C-w>z", ":ZoomToggle<CR>", { noremap = true, silent = true })
