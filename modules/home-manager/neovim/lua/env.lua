local M = {}

---Set an environment variable for the current Neovim session
---@param name string
---@param value string
function M.set(name, value)
    if not name or name == "" then
        vim.notify("Env set: Name required", vim.log.levels.ERROR)
        return
    end
    
    -- Ensure value is at least an empty string if nil
    value = value or ""
    
    vim.env[name] = value
    vim.notify(string.format("Env: %s=%s", name, value), vim.log.levels.INFO)
end

return M
