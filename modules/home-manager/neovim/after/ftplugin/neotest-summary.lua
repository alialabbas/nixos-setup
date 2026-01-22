vim.keymap.set("n", "q", require("neotest").summary.close, { buffer = true })

-- Need to separate select vs mark aka visually selecting thigns vs marking them using the framework
-- TODO: visual is not working as expected
vim.cmd [[:nmenu 10.100 Tests.Run <cmd>:execute "normal r"<CR>]]
vim.cmd [[:amenu 10.101 Tests.Stop <cmd>:execute "normal u"<CR> ]]
vim.cmd [[:nmenu 10.102 Tests.Mark <cmd>:execute "normal m"<CR> ]]
vim.cmd [[:nmenu 10.103 Tests.Clear\ Marked <cmd>:execute "normal M"<CR> ]] -- run select vs marked... This is confusing LOL
vim.cmd [[:nmenu 10.104 Tests.Run\ Marked  <cmd>:execute "normal R"<CR> ]]
vim.cmd [[:nmenu 10.105 Tests.Go\ To\ Test <cmd>:execute "normal i"<CR> ]]
vim.cmd [[:vmenu 10.106 Tests.Run <cmd>:execute "normal rgv"<CR> ]]
vim.cmd [[:vmenu 10.107 Tests.Mark <cmd>:execute "normal mgv"<CR> ]]

vim.keymap.set({ "v", "n" }, "<RightMouse>", "<cmd>:popup Tests<CR>", { buffer = true })
