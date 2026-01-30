---Custom statuscolumn function
---@return string
function _G.MyStatusCol()
    -- 1. FAST PATH: If the buffer is massive, fall back to basic numbers/signs instantly
    -- This prevents the 180k-line search from stuttering even if we forgot to mute it.
    if vim.v.virtnum ~= 0 or vim.api.nvim_buf_line_count(0) > 20000 then
        return "%s%l "
    end

    local lnum = vim.v.lnum
    local f_level = vim.fn.foldlevel(lnum)
    local f_marker = "  " -- Default: empty space

    if f_level > 0 then
        if vim.fn.foldclosed(lnum) ~= -1 then
            f_marker = " " -- Fold is closed
        elseif lnum == vim.fn.foldclosedend(lnum) then
            -- Note: foldclosedend only works on closed folds.
            -- To detect the end of an OPEN fold, we check the next line level.
        elseif vim.fn.foldlevel(lnum - 1) < f_level then
            f_marker = " " -- Start of fold
        elseif vim.fn.foldlevel(lnum + 1) < f_level then
            f_marker = "╰ " -- End of fold (Perfect World!)
        else
            f_marker = "│ " -- Stem
        end
    end

    -- Return: [Signs] [LineNumber] [Padding] [FoldMarker]
    return "%s%=%l " .. f_marker
end

vim.o.signcolumn = "auto:9"
vim.o.statuscolumn = "%!v:lua.MyStatusCol()"
