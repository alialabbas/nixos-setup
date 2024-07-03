require 'possession'.setup({
    autosave = {
        current = true,           -- or fun(name): boolean
        tmp = true,               -- or fun(): boolean
        tmp_name = 'tmp-session', -- or fun(): string
        on_load = true,
        on_quit = true,
    },
})

require('telescope').load_extension('possession')


local events = {
    'CursorHold',
    'BufWinEnter',
    'BufWinLeave',
    'WinNew',
    'WinClosed',
    'TabNew',
}

vim.api.nvim_create_autocmd(events, {
    group = vim.api.nvim_create_augroup('PossessionAutosave', { clear = true }),
    callback = function()
        local session = require('possession.session')
        if session.get_session_name() then
            session.autosave()
        end
    end
})
