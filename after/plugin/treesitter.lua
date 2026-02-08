local ok_configs, ts_configs = pcall(require, "nvim-treesitter.configs")
if not ok_configs then
    return
end

ts_configs.setup({
    ensure_installed = {
        "javascript",
        "python",
        "typescript",
        "go",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",
    },
    auto_install = true,
    sync_install = false,
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
