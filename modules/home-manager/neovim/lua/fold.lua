--- I live this fold style, clean simple effective... Until neovim/vim has hightlight, this is the only way without plugins
function _G.MyFoldText()
    return vim.fn.getline(vim.v.foldstart) .. ' ... ' .. vim.fn.getline(vim.v.foldend):gsub("^%s*", "")
end

vim.opt.foldtext = 'v:lua.MyFoldText()'

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- vim.o.foldtext = ''
vim.o.fillchars = 'fold: '
vim.o.foldmethod = 'expr'
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- require 'ufo'.setup()
-- vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
-- vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:,diff:/]]


-- fixme: should I use this or should I keep the plugin
vim.opt.list = true
-- vim.opt.listchars = {
--     leadmultispace = '│',
--     tab = "> ",
--     -- eol = "¬",
--     trail = "•",
-- }

local indentline_char = '│'

vim.o.listchars = 'trail:•,extends:#,nbsp:.,precedes:❮,extends:❯,tab:› ,leadmultispace:' .. indentline_char .. '  '

local function update(is_local)
    local listchars_update = function(items)
        local listchars = vim.api.nvim_get_option_value('listchars', {})
        for item, val in pairs(items) do
            if listchars:match(item) then
                listchars = listchars:gsub('(' .. item .. ':)[^,]*', '%1' .. val)
            else
                listchars = listchars .. ',' .. item .. ':' .. val
            end
        end
        return listchars
    end
    local new_listchars = ''
    if vim.api.nvim_get_option_value('expandtab', {}) then
        local spaces = vim.api.nvim_get_option_value('shiftwidth', {})
        -- When shiftwidth is 0, vim will use tabstop value
        if spaces == 0 then
            spaces = vim.api.nvim_get_option_value('tabstop', {})
        end
        new_listchars = listchars_update({
            tab = '› ',
            leadmultispace = indentline_char .. string.rep(' ', spaces - 1),
        })
    else
        new_listchars = listchars_update({
            tab = indentline_char .. ' ',
            leadmultispace = '␣'
        })
    end
    local opts = {}
    if is_local then
        opts.scope = 'local'
    end
    vim.api.nvim_set_option_value('listchars', new_listchars, opts)
end

vim.api.nvim_create_augroup('indent_line', { clear = true })
vim.api.nvim_create_autocmd({ 'OptionSet' }, {
    group = 'indent_line',
    pattern = { 'shiftwidth', 'expandtab', 'tabstop' },
    callback = function()
        update(vim.v.option_type == 'local')
    end,
})

vim.api.nvim_create_autocmd({ 'VimEnter' }, {
    group = 'indent_line',
    callback = function()
        update(false)
    end,
})
