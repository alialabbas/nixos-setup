function _G.HighlightedFoldtext()
    local pos = vim.v.foldstart
    local line = vim.api.nvim_buf_get_lines(0, pos - 1, pos, false)[1]
    local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
    local parser = vim.treesitter.get_parser(0, lang)
    local query = vim.treesitter.query.get(parser:lang(), "highlights")

    if query == nil then
        return vim.fn.foldtext()
    end

    local tree = parser:parse({ pos - 1, pos })[1]
    local result = {}
    local line_pos = 0
    local prev_range = nil

    local is_block = false

    for id, node, _ in query:iter_captures(tree:root(), 0, pos - 1, pos) do
        local name = query.captures[id]
        local start_row, start_col, end_row, end_col = node:range()

        if start_row == pos - 1 and end_row == pos - 1 then
            local range = { start_col, end_col }
            if start_col > line_pos and lang == "json" then
                local re = string.rep(" ", start_col - line_pos)
                if #result ~= 0 then re = " " end
                table.insert(result, { re, "Folded" })
            elseif start_col > line_pos then
                table.insert(result, { line:sub(line_pos + 1, start_col), "Folded" })
            end

            line_pos = end_col
            local text = vim.treesitter.get_node_text(node, 0)

            if text == "{" or text == "[" or text == "(" or text == "[|" then is_block = true end
            -- TODO: this is really a json thing only
            if text == '"' and lang == "json" then
                -- vim.notify(text)
            elseif prev_range ~= nil and range[1] == prev_range[1] and range[2] == prev_range[2] then
                result[#result] = { text, "@" .. name }
            else
                table.insert(result, { text, "@" .. name })
            end
            prev_range = range
        end
    end

    table.insert(result, { " ... ", "Folded" })

    local nix_or_nickel = lang == "nickel" or lang == "nix"

    if is_block then
        pos = vim.v.foldend
        for id, node, _ in query:iter_captures(tree:root(), 0, pos - 1, pos) do
            local name = query.captures[id]
            local start_row, start_col, end_row, end_col = node:range()
            if start_row == pos - 1 and end_row == pos - 1 then
                local range = { start_col, end_col }
                line_pos = end_col
                local text = vim.treesitter.get_node_text(node, 0)

                -- TODO: why would I want this?
                if prev_range ~= nil
                    and range[1] == prev_range[1]
                    and range[2] == prev_range[2]
                    and (not nix_or_nickel) then
                    result[#result] = { text, "@" .. name }
                else
                    table.insert(result, { text, "@" .. name })
                end
                prev_range = range
            end
        end
    end

    return result
end

vim.opt.foldtext = 'v:lua.HighlightedFoldtext()'

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
