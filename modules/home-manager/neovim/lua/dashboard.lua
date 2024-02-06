local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Set header
dashboard.section.header.val = {
    "                                                     ",
    "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
    "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
    "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
    "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
    "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
    "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
    "                                                     ",
}

local version = vim.version()
dashboard.section.footer.val = string.format(
    'v%s.%s.%s%s',
    version.major,
    version.minor,
    version.patch,
    version.api_prerelease and ' (Nightly)' or ''
)


-- Set menu
dashboard.section.buttons.val = {
    dashboard.button("e", "  > New file", ":ene <BAR> startinsert <CR>"),
    dashboard.button("f", "  > Find file", ":Telescope find_files<CR>"),
    dashboard.button("p", "  > Projects",
        ':lua = require "telescope".extensions.repo.list({search_dirs={vim.loop.cwd()}})<CR>'),
    dashboard.button("s", "  > Sessions", ":Telescope possession list<CR>"),
    dashboard.button("r", "  > Recent", ":Telescope oldfiles<CR>"),
    dashboard.button("w", "󰛔  > Fuzzy Search", ":Telescope live_grep<CR>"),
    dashboard.button("m", "  > Open Bookmarks", ":Telescope vim_bookmarks<CR>"),
    dashboard.button("q", "󰅚  > Quit NVIM", ":qa<CR>"),
}

dashboard.section.buttons.opts = { position = "center", }

-- Send config to alpha
alpha.setup(dashboard.opts)

-- Disable folding on alpha buffer
vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
]])
