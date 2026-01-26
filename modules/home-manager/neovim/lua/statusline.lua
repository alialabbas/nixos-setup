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
            },
            {
                'diff',
            },
            {
                'diagnostics',
                sources = { 'nvim_diagnostic' },
            },
        },
        lualine_x = { 'encoding', 'fileformat',
            {
                'filetype',
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
