-- WSL is special, set the browser to wslview. NOTE: we are not using $WSL_ENV since that is not set in wslg apps
if vim.cmd.WSL_DISTOR_NAME ~= nil then
    vim.g.netrw_browsex_viewer = "wslview"
end
