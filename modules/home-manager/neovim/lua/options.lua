vim.loader.enable()

local options = {
    sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions,globals",
    title = false,
    termguicolors = true,
    laststatus = 2,
    hlsearch = true,
    incsearch = true,
    mouse = "a",
    undofile = true,
    backup = true,
    writebackup = true,
    ignorecase = true,
    smartcase = true,
    autoread = true,
    list = true,
    showmatch = true,
    showmode = true,
    splitbelow = true,
    splitright = true,
    wildmenu = true,
    wildmode = "longest:full,full",
    wop = "pum",
    backupdir = vim.fn.expand("$XDG_STATE_HOME") .. "/nvim/backup",
    directory = vim.fn.expand("$XDG_STATE_HOME") .. "/nvim/tmp",
    undodir = vim.fn.expand("$XDG_STATE_HOME") .. "/nvim/undo",
    tabstop = 8,
    expandtab = true,
    softtabstop = 2,
    shiftwidth = 4,
    autoindent = true,
    number = true,
    relativenumber = true,
    signcolumn = "yes",
}

for k, v in pairs(options) do
    vim.opt[k] = v
end

-- Remove Search Results from cmdline
vim.o.shortmess = vim.o.shortmess .. "S"


-- Neovide related options
if vim.g.neovide then
    vim.keymap.set('n', '<D-c>', '"+p')
    vim.keymap.set({ 'i', 'c' }, '<D-v>', '<c-r>+')
end
