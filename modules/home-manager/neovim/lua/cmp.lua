local cmp = require "cmp"
cmp.setup {
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete({ select = true }),
        ["<C-e>"] = cmp.mapping.close(),
        ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = {
        { name = "nvim_lsp" },
        { name = "vsnip" },
        { name = "path" },
        { name = "nvim_lua" },
        { name = "git" },
        { name = "conventionalcommits" },
        { name = 'nvim_lsp_signature_help' },
    }
}
cmp.setup.filetype({ 'xml' }, {
    sources = {
        { name = 'csproj', keyword_length = 4 },
        { name = 'vsnip' },
        { name = 'path' }
    }
})
cmp.setup.filetype({ 'markdown', 'text' }, {
    sources = {
        { name = 'buffer' },
    }
})

require("cmp_git").setup()

-- autocompletion for csproj files
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = { '*.csproj' },
    callback = function(args)
        ----- CSPROJ CMP SORUCE
        local source = {}

        ---Return whether this source is available in the current context or not (optional).
        ---@return boolean
        function source:is_available()
            local filename = vim.fn.expand('%:t')
            return string.match(filename, '.csproj$')
        end

        ---Return the debug name of this source (optional).
        ---@return string
        function source:get_debug_name()
            return 'csproj'
        end

        ---Return trigger characters for triggering completion (optional).
        function source:get_trigger_characters()
            return { '.' }
        end

        local Job = require "plenary.job"
        ---Invoke completion (required).
        ---@param params cmp.SourceCompletionApiParams
        ---@param callback fun(response: lsp.CompletionResponse|nil)
        function source:complete(params, callback)
            local cur_line = params.context.cursor_line
            local cur_col = params.context.cursor.col

            local packageRef = string.find(cur_line, 'ProjectReference')
            if packageRef ~= nil then return end                          -- we are on a package ref element, ignore it

            local nuget_name = string.match(cur_line, 'Include="([^"]*)') -- capture the string after include only

            if nuget_name == nil then return end                          -- we need at least an include tag to do something useful here
            local find_version = false

            local _, versionCol = string.find(cur_line, "Version")
            if versionCol ~= nil and cur_col >= versionCol then
                find_version = true
            end
            if find_version == false then
                Job:new {
                    command = "nugetSearch",
                    args = { nuget_name },
                    on_exit = function(job)
                        local items = {}
                        for _, nuget in ipairs(job:result()) do
                            table.insert(items, { label = nuget })
                        end
                        callback(items)
                    end,
                }:sync()
            else
                Job:new {
                    command = "nugetVersions",
                    args = { nuget_name },
                    on_exit = function(job)
                        local items = {}
                        for _, version in ipairs(job:result()) do
                            table.insert(items, { label = version })
                        end
                        callback(items)
                    end,
                }:sync()
            end
        end

        ---Register your source to nvim-cmp.
        require('cmp').register_source('csproj', source)
        vim.api.nvim_del_autocmd(args.id)
    end
})
