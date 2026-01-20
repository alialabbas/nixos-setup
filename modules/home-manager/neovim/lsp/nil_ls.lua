return {
    on_init = function(client)
        client.server_capabilities.completionProvider = nil
        client.server_capabilities.semanticTokensProvider = nil
    end,
    handlers = {
        ["textDocument/completion"] = function() vim.notify_once("nil_ls turned off and won't generated completion") end,
    },
    settings = {
        ["nil"] = {
            formatting = {
                command = { "nixpkgs-fmt" },
            },
        },
    },
}
