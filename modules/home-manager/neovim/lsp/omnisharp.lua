return {
    handlers = {
        ["textDocument/definition"] = require("omnisharp_extended").handler,
    },
    cmd = {
        "OmniSharp",
        "RoslynExtensionsOptions:InlayHintsOptions:EnableForParameters=true",
        "RoslynExtensionsOptions:InlayHintsOptions:ForLiteralParameters=true",
        "RoslynExtensionsOptions:InlayHintsOptions:ForIndexerParameters=true",
        "RoslynExtensionsOptions:InlayHintsOptions:ForObjectCreationParameters=true",
        "RoslynExtensionsOptions:InlayHintsOptions:EnableForTypes=true",
        "RoslynExtensionsOptions:InlayHintsOptions:ForImplicitVariableTypes=true",
        "RoslynExtensionsOptions:InlayHintsOptions:ForLambdaParameterTypes=true",
        "RoslynExtensionsOptions:InlayHintsOptions:ForImplicitObjectCreation=true",
        "--languageserver",
        "--hostPID",
        tostring(vim.fn.getpid()) 
    },
}
