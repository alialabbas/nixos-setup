vim.cmd [[ map <leader>y "+y ]]
vim.cmd [[ map <leader>p "+p]]
vim.api.nvim_set_keymap("n", "<C-C>", ":tabclose<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-[>", ":tabprevious<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-]>", ":tabnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("c", "w!!", "%!sudo tee > /dev/null %", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>/", ":nohlsearch<CR>", { noremap = true, silent = true })
vim.api.nvim_del_keymap("n", "<ESC>")
vim.api.nvim_set_keymap("n", "<leader>z", ":tab split<CR>", { noremap = true, silent = true })
