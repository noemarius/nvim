-- Treesitter syntax highlighting and parsing
local ensure_installed = {
	"bash",
	"c",
	"css",
	"go",
	"html",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"python",
	"query",
	"rust",
	"typescript",
	"typst",
	"vim",
	"vimdoc",
	"yaml",
}

local function install_missing_parsers(treesitter)
	local installed = treesitter.get_installed("parsers")
	local missing = {}

	for _, parser in ipairs(ensure_installed) do
		if not vim.list_contains(installed, parser) then
			table.insert(missing, parser)
		end
	end

	if #missing == 0 then
		return
	end

	local ok_install, install_err = pcall(treesitter.install, missing)
	if not ok_install then
		vim.notify("Treesitter install failed: " .. tostring(install_err), vim.log.levels.WARN)
	end
end

local function ensure_default_parsers()
	local ok, treesitter = pcall(require, "nvim-treesitter")
	if not ok then
		return
	end

	install_missing_parsers(treesitter)
end

local function setup_treesitter()
	local ok, treesitter = pcall(require, "nvim-treesitter")
	if not ok then
		vim.notify("nvim-treesitter not available", vim.log.levels.WARN)
		return
	end

	treesitter.setup({})

	local treesitter_group = vim.api.nvim_create_augroup("custom_treesitter_start", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = treesitter_group,
		pattern = "*",
		callback = function(args)
			pcall(vim.treesitter.start, args.buf)
		end,
	})
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = function()
			vim.cmd("TSUpdate")
			ensure_default_parsers()
		end,
		lazy = false,
		config = setup_treesitter,
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
