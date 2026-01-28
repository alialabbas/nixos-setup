local M = {} 

local has_fish = vim.fn.executable("fish") == 1 

---Query the shell for completions for a given command line 
---@param cmd_line string The full command line to complete (e.g. "git che") 
---@param arg_lead string The part currently being typed 
---@return string[] 
function M.shell_complete(cmd_line, arg_lead) 
    -- If no fish, try to use bash's basic compgen for files/bins 
    -- This is a bit slow for every-keystroke, but for :Task run it is fine. 
    
    if has_fish then 
        -- Fish's 'complete -C' is the gold standard for this. 
        -- It handles the full context of the line. 
        local out = vim.fn.system(string.format("fish -c %s", vim.fn.shellescape("complete -C " .. vim.fn.shellescape(cmd_line)))) 
        if vim.v.shell_error == 0 then 
            local results = {} 
                        for line in out:gmatch("[^\r\n]+") do
                            -- Fish output: "value\tdescription"
                            local parts = vim.split(line, "\t", { plain = true })
                            local val = parts[1]
                            if val then table.insert(results, val) end
                        end
             
            if #results > 0 then return results end 
        end 
    end 

    -- Fallback to basic bash completions 
    -- We use -f (files) and -c (commands) 
    local bash_script = string.format("compgen -f -- %s", vim.fn.shellescape(arg_lead)) 
    local out = vim.fn.system({ "bash", "-c", bash_script }) 
    if vim.v.shell_error == 0 then 
        local results = {} 
        for line in out:gmatch("[^\r\n]+") do 
            table.insert(results, line) 
        end 
        return results 
    end 

    return {} 
end 

return M 
