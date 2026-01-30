local async = require("async")
local M = {}

---Run nix shell and update PATH environment variable
---@param args? string Packages to include in the shell
function M.shell(args)
    if vim.fn.executable("nix") == 0 then
        vim.notify("nix command not found", vim.log.levels.ERROR)
        return
    end

    if not args or args == "" then
        vim.notify("Usage: NixShell <packages...>", vim.log.levels.ERROR)
        return
    end

    -- Split args by space and prefix with nixpkgs# if not already present
    local pkgs = {}
    for pkg in string.gmatch(args, "%S+") do
        if not pkg:find("#") then
            table.insert(pkgs, "nixpkgs#" .. pkg)
        else
            table.insert(pkgs, pkg)
        end
    end

    local cmd = { "nix", "shell" }
    for _, pkg in ipairs(pkgs) do
        table.insert(cmd, pkg)
    end
    table.insert(cmd, "--command")
    table.insert(cmd, "printenv")
    table.insert(cmd, "PATH")

    local path_output = ""
    local error_output = ""
    
    async.run(cmd, {
        sinks = {
            async.sinks.fidget.new(),
            {
                on_stdout = function(_, data)
                    path_output = path_output .. data
                end,
                on_stderr = function(_, data)
                    error_output = error_output .. data
                end,
                on_exit = function(_, obj)
                    if obj.code == 0 then
                        local new_path = vim.trim(path_output)
                        if new_path ~= "" then
                            vim.env.PATH = new_path
                            vim.notify("Nix shell: Environment updated (" .. args .. ")", vim.log.levels.INFO)
                        end
                    else
                        local msg = "Nix shell failed for " .. args
                        if error_output ~= "" then
                            msg = msg .. "\nError: " .. vim.trim(error_output)
                        end
                        vim.notify(msg, vim.log.levels.ERROR)
                    end
                end
            }
        }
    })
end

return M
