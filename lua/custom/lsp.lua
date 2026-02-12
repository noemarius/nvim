-- LSP configuration
-- Mason and server setup are handled by lazy.nvim plugin specs (plugins/lsp.lua)

local remap = require("custom.remap")

-- Diagnostic configuration
vim.diagnostic.config({
    virtual_text = {
        prefix = "●",
        spacing = 2,
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.INFO] = "",
        },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = true,
    },
})

-- Apply LSP keymaps on attach
vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Apply custom LSP keymaps",
    callback = function(event)
        remap.apply_lsp_keymaps({ buffer = event.buf })
    end,
})
