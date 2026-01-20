return {
    handlers = {
        ["textDocument/hover"] = function() end,
    },
    -- settings = {
    --     ['nixd'] = {
    --         eval = {
    --             depth = 10,
    --         },
    --         formatting = {
    --             command = "nixpkgs-fmt",
    --         },
    --         options = {
    --             enable = true,
    --             target = {
    --                 args = {},
    --                 installable = ".#nixosConfigurations.framework.options",
    --             },
    --         },
    --     },
    -- },
}
