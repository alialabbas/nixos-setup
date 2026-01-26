require("lualine").setup({
    sections = {
        lualine_c = {
            {
                'filename',
                path = 1,
                on_click = function(_nb_of_clicks, _button, _modifiers)
                    local filename = vim.fn.getreg('%')
                    vim.cmd("call provider#clipboard#Call('set', [ ['" ..
                        filename .. "'], 'v','\"'])")
                end,
            },
        },
        lualine_b = {
            {
                'branch',
                on_click = function(_nb_of_clicks, _button, _modifiers)
                    vim.cmd("Telescope git_branches")
                end
            },
            {
                'diff',
                on_click = function(_nb_of_clicks, _button, _modifiers)
                    vim.cmd("Telescope git_status")
                end
            },
            {
                'diagnostics',
                sources = { 'nvim_diagnostic' },
                on_click = function(_nb_of_clicks, _button, _modifiers)
                    vim.cmd("Telescope diagnostics")
                end
            },
        },
        lualine_x = { 'encoding', 'fileformat',
            {
                'filetype',
                on_click = function(_nb_of_clicks, _button, _modifiers)
                    vim.cmd("Telescope filetypes")
                end
            },
        },
        lualine_y = { 'progress',
            {
                'searchcount',
            }
        },
        lualine_z = { 'location' },
    },
    options = {
        disabled_filetypes = {
            statusline = {
                "SidebarNvim",
            }
        },
    },
    extensions = { 'nvim-dap-ui', 'toggleterm', 'fugitive', 'quickfix', },
})
