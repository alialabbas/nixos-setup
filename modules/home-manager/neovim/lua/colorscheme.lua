vim.cmd.colorscheme "onehalfdark"

-- From 0.10-dev+ nvim has a default colorscheme with different groups
-- This overrides some of the new links to the old one
-- vim.api.nvim_set_hl(0, "FloatBorder", { link = 'WinSeparator' })
-- vim.api.nvim_set_hl(0, "WinSeparator", { link = 'VertSplit' })
-- -- Yaml keys shouldn't be the same as string highlights
-- vim.api.nvim_set_hl(0, "@field.yaml", { link = "Identifier" })
--
-- -- TODO: make this lua
vim.api.nvim_set_hl(0, "NormalFloat", { link = 'Pmenu' })
vim.cmd [[ hi Pmenu guifg=#dcdfe4 ctermfg=188 ]]
vim.cmd [[ hi Pmenu gui=NONE cterm=NONE ]]
vim.cmd [[ hi Pmenu guibg=#313640 ctermbg=237 ]]
