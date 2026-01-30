vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = {
        '*/templates/*.yaml',
        '*/templates/*.tpl',
        '*.gotempl',
        'helmfile*.yaml',
        'Chart.yaml',
        'values.yaml',
        'values*.yaml',
        '.helmignore',
        'requirements.yaml',
        '*/templates/NOTES.txt'
    },
    callback = function(args)
        -- NOTES.txt and requirements.yaml are not unique to helm
        -- Check them before we do anything else
        local file_name = vim.fn.fnamemodify(args.match, ":t")
        local dir = vim.fn.fnamemodify(args.match, ":h")
        if file_name == "requirements.yaml" then
            if vim.fn.filereadable(vim.fn.fnamemodify(args.match, ":h") .. "Chart.yaml") == 0 then
                return
            end
        elseif file_name == "NOTES.txt" and vim.fn.fnamemodify(args.match, ":h:t") ~= "templates" then
            return
        elseif #vim.fs.find("Chart.yaml", { upward = true, path = dir }) ~= 1 then
            vim.notify("Not a helm directory")
            return
        end

        -- At this point we know any of these yaml files are valid
        if file_name == ".helmignore" then
        elseif
            file_name == "Chart.yaml" or
            file_name == "requirements.yaml" or
            file_name:find("values") ~= nil -- Match "values*"
        then
            vim.opt_local.filetype = 'yaml'
        else
            vim.opt_local.filetype = 'helm'
        end
        vim.opt_local.shiftwidth = 2

        local efm =
            "%.%#%tRROR on %f: %.%#: %.%#: line %l: %m," ..
            "%.%#%tRROR at (%f:%l): %m," ..
            "%.%#[%tRROR] %f: %.%#: %.%#: line %l: %m," ..
            "%.%#[%tRROR] templates/: %.%# (%f:%l): %m," ..
            "%-G%.%#"

        ---Run helm template and show results in a new buffer or quickfix
        local function helm_template()
            local res = vim.system({ "helm", "template", "." }):wait()
            if res.code ~= 0 then
                local processed_lines = vim.system({ "sed", 's/([a-zA-Z]*\\//(/' }, { stdin = res.stderr }):wait()
                vim.fn.setqflist({}, ' ',
                    { title = 'Helm Template . - Errors', lines = vim.split(processed_lines.stdout, "\n"), efm = efm })
                vim.cmd("copen")
                return
            end

            local buf = vim.api.nvim_create_buf(false, false)
            vim.api.nvim_set_option_value("filetype", "yaml", { buf = buf })
            vim.api.nvim_buf_set_name(buf, "TemplatedChart")
            vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
            local win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(win, buf)
            vim.api.nvim_buf_set_text(buf, 0, 0, 0, 0, vim.split(res.stdout, "\n"))
            vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
            vim.api.nvim_set_option_value("buftype", "nowrite", { buf = buf })
        end

        vim.api.nvim_create_user_command("HelmTemplate", function() helm_template() end, {})
        vim.opt_local.makeprg = "helm lint . \\| sed 's/([a-zA-Z_\\-]*\\//(/'"
        vim.opt_local.errorformat =
            "%.%#%tRROR on %f: %.%#: %.%#: line %l: %m," ..
            "%.%#%tRROR at (%f:%l): %m," ..
            "%.%#[%tRROR] %f: %.%#: %.%#: line %l: %m," ..
            "%.%#[%tRROR] templates/: %.%# (%f:%l): %m," ..
            "%-G%.%#"
    end
})

vim.api.nvim_create_autocmd({ 'FileType', }, {
    pattern = "helm",
    callback = function()
        vim.opt_local.commentstring = "{{/*\\ %s */}}"
        -- Manual load because the plugin has a bad ftdetect and I don't want too use it
        vim.cmd("packadd! vim-helm")
    end
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = {
        '*/playbooks/*.yml',
        '*/playbooks/*.yaml',
        '*/tasks/*.yml',
        '*/tasks/*.yaml',
        '*/roles/*.yml',
        '*/roles/*.yaml',
        '*/handlers/*.yml',
        '*/handlers/*.yaml',
        '*/group_vars/*',
        '*/host_vars/*',
        'site.yml',
        'site.yaml',
    },
    callback = function()
        vim.opt_local.filetype = 'yaml.ansible'
        vim.opt_local.shiftwidth = 2
        vim.cmd("packadd ansible-vim")
    end
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = { "Dockerfile*", "DockerFile*" },
    callback = function() vim.opt_local.filetype = 'dockerfile' end
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = { 'flake.lock', },
    callback = function() vim.opt_local.filetype = 'json' end
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = { '*.ncl', },
    callback = function(opts)
        vim.api.nvim_set_option_value("filetype", "nickel", { buf = opts.buffer })
        vim.api.nvim_set_option_value("commentstring", "# %s", { buf = opts.buffer })
    end
})

--TODO: this probably should be done for large files to load them fast
--The issue is foldtext expression running on large files causing slow load
vim.api.nvim_create_autocmd({ 'FileType', }, {
    pattern = "git",
    callback = function()
        vim.opt_local.foldtext = ''
        vim.opt_local.foldmethod = 'manual'
        vim.opt_local.foldenable = false
    end
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = { '*.csproj' },
    callback = function(args)
        local source = {}

        function source:is_available()
            return vim.fn.expand('%:e') == 'csproj'
        end

        function source:get_debug_name()
            return 'csproj'
        end

        function source:get_trigger_characters()
            return { '.' }
        end

        function source:complete(params, callback)
            local cur_line = params.context.cursor_line
            local cur_col = params.context.cursor.col

            if string.find(cur_line, 'ProjectReference') then return end

            local nuget_name = string.match(cur_line, 'Include="([^"]*)')
            if nuget_name == nil then return end

            local find_version = false
            local _, versionCol = string.find(cur_line, "Version")
            if versionCol ~= nil and cur_col >= versionCol then
                find_version = true
            end

            local command = find_version and "nugetVersions" or "nugetSearch"
            local Job = require "plenary.job"
            Job:new {
                command = command,
                args = { nuget_name },
                on_exit = function(job)
                    local items = {}
                    for _, val in ipairs(job:result()) do
                        table.insert(items, { label = val })
                    end
                    callback(items)
                end,
            }:start()
        end

        require('cmp').register_source('csproj', source)
        vim.api.nvim_del_autocmd(args.id)
    end
})

