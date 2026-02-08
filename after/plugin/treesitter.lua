local ok, ts = pcall(require, "nvim-treesitter")
if not ok then
    return
end

-- Install desired parsers (async, no-op if already present)
ts.install({
    "javascript", "python", "typescript", "go", "lua",
    "vim", "vimdoc", "query", "markdown", "markdown_inline",
})

-- Enable treesitter highlighting for all filetypes that have a parser
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("nma_treesitter_hl", { clear = true }),
    callback = function(ev)
        if pcall(vim.treesitter.start, ev.buf) then
            -- Disable legacy syntax highlighting when treesitter is active
            vim.bo[ev.buf].syntax = ""
        end
    end,
})
