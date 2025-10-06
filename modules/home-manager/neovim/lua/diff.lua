---wrapper to allow nvim to diff directories or files
---@param dir1 string
---@param dir2 string
local function diff_dirs(dir1, dir2)
    if type(dir1) ~= "string" then
        error("Expected a string")
    end

    if type(dir2) ~= "string" then
        error("Expected a string")
    end

    if vim.fn.filereadable(dir1) == 1 and vim.fn.filereadable(dir2) == 1 then
        vim.cmd('tabnew')
        vim.cmd('edit ' .. dir1)
        vim.cmd('diffthis')
        vim.cmd('vsplit ' .. dir2)
        vim.cmd('diffthis')
    elseif vim.fn.isdirectory(dir1) == 1 and vim.fn.isdirectory(dir2) == 1 then
        vim.notify(string.format("Diffing %s and %s", dir1, dir2))
        local files1 = vim.iter(vim.fn.glob(dir1 .. '/**', false, true))
            :filter(function(elem) return vim.fn.filereadable(elem) == 1 end)
            :totable()
        local files2 = vim.iter(vim.fn.glob(dir2 .. '/**', false, true))
            :filter(function(elem) return vim.fn.filereadable(elem) == 1 end)
            :totable()

        local files_in_both = {}
        local files_only_in_1 = {}
        local files_only_in_2 = {}

        local files2_map = {}
        for _, file in ipairs(files2) do
            files2_map[vim.fn.fnamemodify(file, ':t')] = file
        end

        for _, file1 in ipairs(files1) do
            local basename = vim.fn.fnamemodify(file1, ':t')
            if files2_map[basename] then
                table.insert(files_in_both, { file1, files2_map[basename] })
                files2_map[basename] = nil
            else
                table.insert(files_only_in_1, file1)
            end
        end

        for _, file2 in pairs(files2_map) do
            table.insert(files_only_in_2, file2)
        end

        for _, files in ipairs(files_in_both) do
            vim.cmd('tabnew')
            vim.cmd('edit ' .. files[1])
            vim.cmd('diffthis')
            vim.cmd('vsplit ' .. files[2])
            vim.cmd('diffthis')
        end

        for _, file in ipairs(files_only_in_1) do
            vim.cmd('tabnew ' .. file)
        end

        for _, file in ipairs(files_only_in_2) do
            vim.cmd('tabnew ' .. file)
        end
    else
        error("Both args should be directories or files")
    end
end

vim.api.nvim_create_user_command('Diff', function(opts)
    local args = vim.split(opts.args, ' ')
    if #args ~= 2 then
        print('Usage: Diff <dir1|file1> <dir2|file2>')
        return
    end
    diff_dirs(args[1], args[2])
end, { nargs = '*' })
