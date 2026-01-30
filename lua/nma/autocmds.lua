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

-- api.nvim_create_autocmd("VimEnter", {
-- 	callback = function()
-- 		if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
-- 			pcall(vim.cmd, "Neotree close")
-- 		end
-- 	end,
-- })
