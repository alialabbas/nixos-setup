-- Simple handler to prefix ansible file location with file scheme which what neovim client expect
local function ansible_handler(err, result, ctx, config)
    if result == nil then
        return
    end
    result[1].targetUri = "file://" .. result[1].targetUri

    return vim.lsp.handlers['textDocument/definition'](err, result, ctx, config)
end

return {
    handlers = {
        ["textDocument/definition"] = ansible_handler
    },
}
