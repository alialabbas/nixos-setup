return {
    settings = {
        gopls = {
            semanticTokens = true,
            ["ui.inlayhint.hints"] = {
                compositeLiteralFields = true,
                constantValues = true,
                parameterNames = true
            },
        },
    },
}
