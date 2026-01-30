local M = {}

M.config = {
    -- Layer 1: Local project markers (we'll use the deepest one found)
    layer1 = { 'go.mod', 'package.json', 'Makefile', 'Cargo.toml', 'project.clj', 'build.boot', 'deps.edn', '*.sln' },
    -- Layer 2: Ultimate project markers (take precedence and stop search)
    layer2 = { '.git', '_darcs', '.hg', '.bzr', '.svn' }
}

---Find the project root based on markers
---@return string|nil
local function find_root()
    local path = vim.api.nvim_buf_get_name(0)
    if path == "" then return nil end

    -- Handle Oil buffers by stripping the prefix and using the directory directly
    if path:match("^oil://") then
        path = path:gsub("^oil://", "")
    else
        path = vim.fs.dirname(path)
    end

    local root_layer1 = nil

    ---@param dir string
    ---@return string|nil
    local function check_dir(dir)
        -- Check Layer 2 first (Ultimate markers)
        for _, pattern in ipairs(M.config.layer2) do
            local matches = vim.fn.glob(dir .. '/' .. pattern)
            if matches ~= "" then
                return dir -- Found Layer 2, stop immediately and return this
            end
        end

        -- Check Layer 1 (Local markers)
        if not root_layer1 then
            for _, pattern in ipairs(M.config.layer1) do
                local matches = vim.fn.glob(dir .. '/' .. pattern)
                if matches ~= "" then
                    root_layer1 = dir -- Remember the first (deepest) Layer 1 marker
                end
            end
        end
        return nil
    end

    -- Check the file's directory first
    local res = check_dir(path)
    if res then return res end

    -- Traverse up the tree
    for dir in vim.fs.parents(path) do
        res = check_dir(dir)
        if res then return res end
    end

    return root_layer1
end

---Change directory to the project root
function M.root()
    -- Only run for normal buffers or Oil buffers
    if vim.bo.buftype ~= "" and vim.bo.filetype ~= "oil" then return end

    local root = find_root()
    if root and root ~= vim.fn.getcwd() then
        -- Use tcd to keep it local to the tab
        vim.cmd("tcd " .. vim.fn.fnameescape(root))
    end
end

---Initialize rooter with custom config
---@param opts? table
function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

-- Define the autocommand immediately so it runs with defaults upon require
vim.api.nvim_create_autocmd({ "VimEnter", "TabEnter" }, {
    group = vim.api.nvim_create_augroup("TabRooter", { clear = true }),
    callback = function()
        -- We use a timer to defer execution slightly, ensuring the buffer is fully loaded
        -- and avoid issues during startup or rapid tab switching.
        vim.schedule(function()
            M.root()
        end)
    end,
})

return M