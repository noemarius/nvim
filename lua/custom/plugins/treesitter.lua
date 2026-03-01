-- Treesitter syntax highlighting and parsing
return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false,
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
				"typst",
				"c",
				"rust",
			}

			local ok, treesitter = pcall(require, "nvim-treesitter")
			if not ok then
				vim.notify("nvim-treesitter not available", vim.log.levels.ERROR)
				return
			end

			treesitter.setup({})
			treesitter.install(ensure_installed)
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
