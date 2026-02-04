local vim = vim
local api = vim.api

local function set_indent(bufnr, width)
	local buffer = vim.bo[bufnr]
	buffer.shiftwidth = width
	buffer.tabstop = width
	buffer.softtabstop = width
	buffer.expandtab = true
end

local indent_group = api.nvim_create_augroup("nma_indent", { clear = true })

api.nvim_create_autocmd("FileType", {
	group = indent_group,
	pattern = {
		"lua",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"json",
		"yaml",
		"html",
		"css",
		"scss",
	},
	callback = function(args)
		set_indent(args.buf, 2)
	end,
})

api.nvim_create_autocmd("FileType", {
	group = indent_group,
	pattern = {
		"python",
		"go",
		"rust",
		"java",
		"c",
		"cpp",
	},
	callback = function(args)
		set_indent(args.buf, 4)
	end,
})

-- Open opencode panel on startup if .opencode config exists in cwd
local opencode_group = api.nvim_create_augroup("nma_opencode", { clear = true })

api.nvim_create_autocmd("VimEnter", {
	group = opencode_group,
	desc = "Open opencode panel on startup if project has .opencode config",
	callback = function()
		-- Check if .opencode directory or file exists in cwd
		local opencode_config = vim.fn.getcwd() .. "/.opencode"
		if vim.fn.isdirectory(opencode_config) == 1 or vim.fn.filereadable(opencode_config) == 1 then
			-- Defer to ensure all plugins are loaded
			vim.defer_fn(function()
				local ok, opencode = pcall(require, "opencode")
				if ok then
					opencode.toggle()
				end
			end, 100)
		end
	end,
})
