-- Minimal Terminal Utility
-- Enforces naming scheme: term://<cwd>//<Name>

--------------------------------------------------------------------------------
-- The Flexible ":Term" Command
--------------------------------------------------------------------------------
-- Usage:
-- :Term                    -> New terminal with unique ID (Shell)
-- :Term <name>             -> New or Existing terminal named <name> (Shell)
-- :Term <name> <cmd...>    -> New terminal named <name> running <cmd>

local function get_term_name(suffix)
    return "term://" .. vim.fn.getcwd() .. "//" .. suffix
end

vim.api.nvim_create_user_command("Term", function(opts)
    local args = opts.fargs
    local name = args[1]
    local cmd = nil

    -- Parse Arguments
    if #args > 1 then
        -- If more than 1 arg, the rest is the command
        cmd = table.concat(args, " ", 2)
    end

    -- Generate unique name if not provided
    if not name or name == "" then
        -- Use timestamp + random key for uniqueness
        name = tostring(os.time()) .. "-" .. math.random(1000)
    end

    local target_name = get_term_name(name)
    local existing_buf = vim.fn.bufnr(target_name)

    if existing_buf ~= -1 and vim.api.nvim_buf_is_valid(existing_buf) then
        -- Buffer exists: Switch to it
        -- We ignore 'cmd' here. To run a new command in the same name,
        -- the user should close the old one first.
        vim.api.nvim_set_current_buf(existing_buf)
    else
        -- Create New
        if cmd then
            vim.cmd("terminal " .. cmd)
        else
            vim.cmd("terminal")
        end

        -- Rename to our schema
        -- Wrap in pcall just in case of weird race conditions or format issues
        pcall(vim.api.nvim_buf_set_name, 0, target_name)

        -- Setup Env (Only for interactive shells)
        -- If running a direct command (like 'make'), sending text to stdin
        -- might break it or be ignored.
        if not cmd and vim.fn.filereadable(".env") ~= 0 then
            vim.api.nvim_chan_send(vim.bo.channel, "source .env\nclear\n")
        end

        -- Clean settings
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.statuscolumn = ''

        -- Clean up buffer when the process exits
        vim.api.nvim_create_autocmd({ 'TermClose' }, {
            buffer = 0,
            callback = function(close_args)
                if vim.api.nvim_buf_is_loaded(close_args.buf) then
                    vim.api.nvim_buf_delete(close_args.buf, { force = true })
                end
            end
        })
    end
end, {
    nargs = "*",
    complete = "shellcmd"
})

-- Terminal Keymaps
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { noremap = true, silent = true })
