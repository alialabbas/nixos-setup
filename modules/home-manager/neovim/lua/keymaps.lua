vim.cmd [[ map <leader>y "+y ]]
vim.cmd [[ map <leader>p "+p]]
local opt = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<C-C>", ":tabclose<CR>", opt)
vim.api.nvim_set_keymap("n", "<C-[>", ":tabprevious<CR>", opt)
vim.api.nvim_set_keymap("n", "<C-]>", ":tabnext<CR>", opt)
vim.api.nvim_set_keymap("c", "w!!", "%!sudo tee > /dev/null %", opt)
vim.api.nvim_set_keymap("n", "<leader>/", ":nohlsearch<CR>", opt)
vim.api.nvim_del_keymap("n", "<ESC>")
vim.api.nvim_set_keymap("n", "<leader>z", ":tab split<CR>", opt)

vim.api.nvim_set_keymap("i", "<C-h>", "<Left>", opt)
vim.api.nvim_set_keymap("i", "<C-j>", "<Down>", opt)
vim.api.nvim_set_keymap("i", "<C-k>", "<Up>", opt)
vim.api.nvim_set_keymap("i", "<C-l>", "<Right>", opt)
vim.api.nvim_set_keymap("c", "<C-h>", "<Left>", opt)
vim.api.nvim_set_keymap("c", "<C-j>", "<Down>", opt)
vim.api.nvim_set_keymap("c", "<C-k>", "<Up>", opt)
vim.api.nvim_set_keymap("c", "<C-l>", "<Right>", opt)
