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
            vim.api.nvim_buf_set_option(buf, "filetype", "yaml")
            vim.api.nvim_buf_set_name(buf, "TemplatedChart")
            vim.api.nvim_buf_set_option(buf, "swapfile", false)
            local win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(win, buf)
            vim.api.nvim_buf_set_text(buf, 0, 0, 0, 0, vim.split(res.stdout, "\n"))
            vim.api.nvim_buf_set_option(buf, "modifiable", true)
            vim.api.nvim_buf_set_option(buf, "buftype", "nowrite")
        end

        vim.api.nvim_create_user_command("HelmTemplate", function() helm_template() end, {})
        vim.opt_local.makeprg = "helm lint . \\| sed 's/([a-zA-Z]*\\//(/'"
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
        vim.cmd("packadd! ansible-vim")
    end
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern  = { '*.nix' },
    callback = function(args)
        vim.cmd("packadd! vim-nixhash")
        vim.cmd("packadd! vim-nix")
        vim.api.nvim_del_autocmd(args.id)
    end,
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
    callback = function()
        vim.treesitter.query.set("nickel", "folds",
            "[ (let_in_block) (fun_expr) (uni_record) (record_field) (ite_expr) (atom) (match_expr)]@fold")
    end
})
