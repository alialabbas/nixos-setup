return {
    init_options = { documentFormatting = true },
    filetypes = { "sh", "json", "markdown", "dockerfile" },
    settings = {
        languages = {
            sh = {
                {
                    formatCommand = 'shfmt -ci -s -bn',
                    formatStdin = true,
                    lintCommand = 'shellcheck -f gcc -x',
                    lintSource = 'shellcheck',
                    lintFormats = { '%f:%l:%c: %trror: %m', '%f:%l:%c: %tarning: %m', '%f:%l:%c: %tote: %m' }
                }
            },
            json = {
                {
                    lintCommand = 'jq .',
                    formatCommand = 'jq .',
                    formatStdin = true,
                    lintStdin = true,
                    lintOffset = 1,
                    lintFormats = { '%m at line %l, column %c', },
                },
            },
            markdown = {
                {
                    lintCommand = "markdownlint -s",
                    lintSource = "markdownlint",
                    lintStdin = true,
                    lintFormats = { '%f:%l %m', '%f:%l:%c %m', '%f: %l: %m' },
                },
            },
            dockerfile = {
                {
                    lintCommand = 'hadolint --no-color',
                    lintFormats = { '%f:%l %m' },
                }
            },
        }
    }
}
