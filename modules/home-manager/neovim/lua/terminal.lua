--- Simple Per Tab Terminal Manager
--- Treats terminal as a buffer like how vim intended and just move it around if necessary
--- Hide when it is the last window in the layout tree aka last vertical or last horizontal
--- Move terminal between different toggle modules
--- Same toggle mode == Hide
--- Differente toggle mode == Move

--- Return the tab page number similar to tabnr() which what autocmd would see to allow
--- correctly managing the terminals
---@return integer
local function get_current_tab()
    return vim.api.nvim_tabpage_get_number(vim.api.nvim_get_current_tabpage())
end

--- Config to control the default sizes and the command to call for each terminal tab
local config = {
    vertical = {
        size = "vertical resize 80",
        create = "botright vsplit term://bash",
        restore = "botright vsplit",
    },
    horizontal = {
        size = "resize 20",
        create = "botright split term://bash",
        restore = "botright split",
    },
    tab = {
        size = "",
        create = "terminal",
        restore = "",
    },
}


local function add_details(layout)
    if layout[1] == "leaf" then
        local win = layout[2]

        -- window options
        local all_options = vim.api.nvim_get_all_options_info()
        local v = vim.wo[win]
        local options = {}
        for key, val in pairs(all_options) do
            if val.global_local == false and val.scope == "win" then
                options[key] = v[key]
            end
        end

        -- create dict structure with added buffer and window opts
        ---@type _layout
        local l = {
            type = layout[1],
            winid = win,
            bufnr = vim.fn.winbufnr(win),
            win_opts = options,
            cursor = vim.api.nvim_win_get_cursor(win),
            is_curr_win = vim.api.nvim_get_current_win() == win
        }
        return l
    else
        local children = {}
        for _, child_layout in ipairs(layout[2]) do
            table.insert(children, add_details(child_layout))
        end
        return { type = layout[1], children = children }
    end
end


-- Leaf means we are the only window aka full TabTerm
-- row means it is a vertical split and we are indeed the last one
-- col means it is a horizontal split and we are the last one
--- @return node_type, number
local get_last_window = function()
    local layout = vim.fn.winlayout()
    local position = layout[1]
    while type(layout) ~= "number" do
        layout = layout[#layout]
    end

    return position, layout
end

local function apply_layout(layout)
    if layout.type == "leaf" then
        -- open the previous buffer
        -- TODO: somehow, this even when the buffer is deleted, it is still able to load it back
        if vim.fn.bufexists(layout.bufnr) == 1 then
            vim.cmd("b " .. layout.bufnr)
        end
        -- apply window options
        -- for opt, val in pairs(layout.win_opts) do
        --     if val ~= nil then
        --         vim.wo[opt] = val
        --     end
        -- end

        vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), layout.cursor)
    else
        -- split cols or rows, split n-1 times
        local split_method = "rightbelow vsplit"
        if layout.type == "col" then
            split_method = "rightbelow split"
        end

        local wins = { vim.fn.win_getid() }

        for i in ipairs(layout.children) do
            if i ~= 1 then
                vim.cmd(split_method)
                table.insert(wins, vim.fn.win_getid())
            end
        end

        -- recursive into child windows
        for index, win in ipairs(wins) do
            vim.fn.win_gotoid(win)
            apply_layout(layout.children[index])
        end
    end
end



local function save()
    local layout = vim.fn.winlayout()
    local restore_cmd = vim.fn.winrestcmd()

    layout = add_details(layout)
    return { layout = layout, restore = restore_cmd, focused_buf = vim.api.nvim_get_current_buf() }
end

local function restore(egg)
    egg = egg or {}

    if not egg.layout or not egg.restore then
        return
    end

    vim.cmd("only")

    -- apply layout and perform resize_cmd
    -- TODO: this needs to return the caller if it was able to restore the layout or note
    -- Basically, in the case of terminal, we want to make sure we don't persist an invalid layout anymore
    -- that was :bwipeout and then lose the terminal for good
    -- terminal checks, if no layout applied, wipe the old layout and continute with your life as normal until a new layout exist in the tabpage
    apply_layout(egg.layout)
    vim.cmd(egg.restore)

    for _, w in pairs(vim.api.nvim_tabpage_list_wins(0)) do
        local winbuf = vim.api.nvim_win_get_buf(w)
        if winbuf == egg.focused_buf then
            vim.api.nvim_set_current_win(w)
            break
        end
    end

    -- delete temporary buffer
    -- vim.cmd("bd " .. tmp_buf)
end

-- remember mode here is the shitty part, no matter how you play this bingo, unless I can know if this is taking a full row or not, I can't just flip

local terminals = {}
local layouts = {}
-- vim.fn.winlayout() ---> We should be abel to walk this tree and figure out how to restore the window laytou
-- This proof of concept work... Now again it is only a matter of figuring out how to get
-- back the terminal buffer and let it take over
-- Rather than a command, this is more if a keybind to automated this process that
-- I usually would want to do
-- What is missing is to add a termopen hook to load few commands on boot like activating a nix shell
-- Or source .env file
vim.api.nvim_create_autocmd({ 'TermOpen', }, {
    pattern = "*",
    callback = function(args)
        if args.file:find("bash") then
            -- only clean up for the current buffer terminal
            vim.api.nvim_create_autocmd({ 'TermClose', }, {
                pattern = args.file,
                callback = function(close_args)
                    if vim.api.nvim_buf_is_loaded(close_args.buf) then
                        vim.api.nvim_buf_delete(close_args.buf, { force = true })
                    end

                    -- we still want random terminals to operate in a short span and only care about the one is loaded with the toggle methods
                    if args.buf == terminals[get_current_tab()] then
                        terminals[get_current_tab()] = nil
                    end
                end
            })
        end
        if vim.fn.filereadable(".env") ~= 0 then
            vim.api.nvim_chan_send(vim.bo.channel, "source .env\nclear\n") -- TODO: return char should be os driven
        end
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.statuscolumn = ''
    end
})

vim.api.nvim_create_autocmd({ 'TermEnter', }, {
    pattern = "*",
    callback = function(args)
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.statuscolumn = ''
    end
})

-- TODO: need to move the tabs around here
vim.api.nvim_create_autocmd("TabClosed", {
    callback = function(args)
        local tab_id = tonumber(args.file)
        local buf = terminals[tab_id]
        terminals[tab_id] = nil

        if buf ~= nil then
            local channel = vim.api.nvim_buf_get_option(buf, "channel")
            vim.api.nvim_chan_send(channel, "exit\n")
        end
    end,
})

---create a terminal bound to the current tab
---@param open_cmd string
---@param resize_cmd string
---@param direction direction
local create_tab_term = function(open_cmd, resize_cmd, direction)
    local tab_id = get_current_tab()
    if not terminals[tab_id] or not vim.api.nvim_buf_is_valid(terminals[tab_id]) then
        if direction == "tab" then layouts[tab_id] = save() end
        vim.cmd(open_cmd)
        terminals[tab_id] = vim.api.nvim_get_current_buf()
        vim.cmd(resize_cmd)

        -- -- only clean up for the current buffer terminal
        -- vim.api.nvim_create_autocmd({ 'TermClose', }, {
        --     pattern = vim.api.nvim_buf_get_name(0),
        --     callback = function(args)
        --         if vim.api.nvim_buf_is_loaded(args.buf) then
        --             vim.api.nvim_buf_delete(args.buf, { force = true })
        --         end
        --
        --         -- we still want random terminals to operate in a short span and only care about the one is loaded with the toggle methods
        --         if args.buf == terminals[get_current_tab()] then
        --             terminals[get_current_tab()] = nil
        --         end
        --     end
        -- })


        return true
    end
    return false
end

---@alias direction "vertical" | "horizontal" | "tab"
---@alias node_type "row" | "col" | "leaf"
---comment
---@param position node_type
---@return direction
local translate_layout = function(position)
    if position == "row" then
        return "vertical"
    elseif position == "col" then
        return "horizontal"
    elseif position == "leaf" then
        return "tab"
    else
        error("received an invalid position " .. position)
    end
end

---check if the last terminal in the layout is the terminal bound to the manager or not
---returns a tuple, bound or not, the layout and the window handler
---@return boolean
---@return "horizontal"|"tab"|"vertical"
---@return integer
local is_last_window_term = function()
    local tab_id = get_current_tab()
    local position, win_id = get_last_window()
    if vim.api.nvim_win_get_buf(win_id) == terminals[tab_id] then
        return true, translate_layout(position), win_id
    end
    return false, "horizontal", 0
end

--- Restore the terminal into its correctly position
---@param open_cmd string
---@param resize_cmd string
local restore_tab_term = function(open_cmd, resize_cmd)
    local tab_id = get_current_tab()
    vim.cmd(open_cmd)
    vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), terminals[tab_id])
    vim.cmd(resize_cmd)
end

--- We want to close the bounded terminal regardless of its location
--- Useful when to allow the terminal to be treated as a buffer that can be restored to its
--- desired layout at any point of time
local close_tab_terminal_windows = function()
    local windows = vim.api.nvim_tabpage_list_wins(0)
    local tab_id = get_current_tab()
    for _, win in pairs(windows) do
        if vim.api.nvim_win_get_buf(win) == terminals[tab_id] then
            vim.api.nvim_win_close(win, true)
        end
    end
end

---Toggle the terminal bound to the current tab page and create a new one if necessary
---@param direction direction
local toggle = function(direction)
    local tab_id = get_current_tab()
    if create_tab_term(config[direction].create, config[direction].size, direction) then return end

    local is_term, prev_direction, win_id = is_last_window_term()

    if is_term then
        -- always close the term and exit early if we are in the same direction
        if prev_direction == "tab" then
            restore(layouts[tab_id])
            layouts[tab_id] = nil
        else
            close_tab_terminal_windows()
            -- vim.api.nvim_win_close(win_id, true) -- This shouldn't happen in the tab case
        end

        if direction == prev_direction then return end
    else
        -- should this maybe be inside the restore
        close_tab_terminal_windows()
    end

    if direction == "tab" then
        layouts[tab_id] = save()
        vim.cmd("only")
    end

    restore_tab_term(config[direction].restore, config[direction].size)
end

vim.api.nvim_create_user_command("HorzTerm", function()
    toggle("horizontal")
end, {})

vim.api.nvim_create_user_command("VertTerm", function()
    toggle("vertical")
end, {})


vim.api.nvim_create_user_command("TabTerm", function()
    toggle("tab")
end, {})


local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<C-T>v", ":VertTerm<CR>", opts)
vim.keymap.set("n", "<C-T>h", ":HorzTerm<CR>", opts)
vim.keymap.set("n", "<C-T>t", ":TabTerm<CR>", opts)
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
