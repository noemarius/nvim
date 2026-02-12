-- Treesitter syntax highlighting and parsing
return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            -- Parsers to ensure are installed
            local ensure_installed = {
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
                "html",
                "css",
                "json",
                "yaml",
                "bash",
                "c",
                "rust",
            }

            -- Schedule parser installation for missing languages
            vim.schedule(function()
                for _, lang in ipairs(ensure_installed) do
                    local ok = pcall(vim.treesitter.language.inspect, lang)
                    if not ok then
                        vim.cmd("TSInstall " .. lang)
                    end
                end
            end)
        end,
    },

    -- Treesitter context (shows function/class context at top)
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = "VeryLazy",
        opts = {
            max_lines = 3,
            trim_scope = "outer",
        },
    },
}
