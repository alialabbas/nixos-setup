local update_nixd_settings = function()
    local cfgs = {}

    local merge_cfgs = function(_, data, event)
        if event == "stdout" and data then
            local table_cfg = vim.json.decode(data[1])
            for _, home_cfg in ipairs(table_cfg) do
                table.insert(cfgs, "homeConfigurations." .. home_cfg)
            end
        end
    end

    local on_event = function(job_id, data, event)
        if event == "stdout" and data then
            local nixos_cfgs = vim.json.decode(data[1])
            for _, nixos_cfg in ipairs(nixos_cfgs) do
                table.insert(cfgs, "nixosConfigurations." .. nixos_cfg)
            end

            vim.ui.select(cfgs, { label = '> ' }, function(choice)
                local settings = {
                    ['nixd'] = {
                        eval = {
                            depth = 10,
                        },
                        formatting = {
                            command = "nixpkgs-fmt",
                        },
                        options = {
                            enable = true,
                            target = {
                                args = {},
                                installable = string.format(".#%s.options", choice),
                            },
                        },
                    },
                }

                for _, client in ipairs(vim.lsp.get_clients({ name = "nixd" })) do
                    local result = client.notify("workspace/didChangeConfiguration",
                        {
                            settings = settings,
                        }
                    )
                    vim.notify("updated config " .. tostring(result));
                    client.config.settings = settings
                end
            end)
        end
    end

    local job_id = vim.fn.jobstart('nix eval .#homeConfigurations --apply builtins.attrNames --json',
        { on_stdout = merge_cfgs, stdout_buffered = true })

    vim.fn.jobwait({ job_id })

    vim.fn.jobstart('nix eval .#nixosConfigurations --apply builtins.attrNames --json',
        { on_stdout = on_event, stdout_buffered = true })
end

-- Create the command only for the current buffer (Nix file)
vim.api.nvim_buf_create_user_command(0, "NixUpdateSettings", update_nixd_settings, {})
