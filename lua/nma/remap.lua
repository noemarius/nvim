local M = {}

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open netrw file explorer" })
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines (cursor stays)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })
vim.keymap.set(
	"n",
	"<leader>cd",
	'<cmd>lua vim.diagnostic.open_float()<CR><cmd>lua vim.diagnostic.open_float()<CR>ggVG"+Y<CR>',
	{ desc = "Copy diagnostics to clipboard" }
)

-- Optional diagnostic navigation helpers
-- vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
-- vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
-- vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Diagnostic hover" })
-- vim.keymap.set("n", "<leader>e", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- vim.keymap.set("n", "n", "nzzzv") -- Center cursor after searching next occurrence
-- vim.keymap.set("n", "N", "Nzzzv") -- Center cursor after searching previous occurrence

vim.keymap.set("n", "<leader>/", ":nohl<CR>", { desc = "Clear search highlight" })
vim.keymap.set("x", "<leader>p", [['_dP]], { desc = "Paste without overwriting register" })

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to black hole register" })

-- Optional buffer management
-- vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
-- vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Prev buffer" })
-- vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

vim.keymap.set("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Force quit Neovim" })
vim.keymap.set("n", "<leader>q", "<cmd>qa<CR>", { desc = "Quit Neovim" })

-- Quick write/source ideas
-- vim.keymap.set("n", "<leader>w", ":write<CR>", { desc = "Save file" })
-- vim.keymap.set("n", "<leader>W", ":wall<CR>", { desc = "Save all" })
-- vim.keymap.set("n", "<leader><leader>", function() vim.cmd("so") end, { desc = "Source current file" })

vim.keymap.set("n", "Q", "<nop>", { desc = "Disable Ex mode" })
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format with LSP" })

-- Optional LSP convenience bindings
-- vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
-- vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
-- vim.keymap.set("n", "<leader>fm", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format buffer" })
-- vim.keymap.set("n", "gh", vim.lsp.buf.hover, { desc = "Hover info" })
-- vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Goto implementation" })

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Prev quickfix item" })
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Next loclist item" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Prev loclist item" })

-- Optional window management helpers
-- vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Vertical split" })
-- vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Horizontal split" })
-- vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Balance windows" })
-- vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Left window" })
-- vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Lower window" })
-- vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Upper window" })
-- vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Right window" })

vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Replace word under cursor" }
)
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })

vim.keymap.set("n", "<leader>ge", "oif err != nil {<CR>}<Esc>Oreturn nil, err<Esc>", { desc = "Go error snippet" })

vim.keymap.set("n", "<leader>vpp", "<cmd>e ~/.config/nvim/lua/nma/packer.lua<CR>", { desc = "Edit packer.lua" })
vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>", { desc = "Make it rain" })

vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
	vim.notify("Sourced current file")
end, { desc = "Source current file" })

-- Wraps opencode-specific mappings so they only run when the plugin is available.
local function map_opencode(modes, lhs, handler, desc)
	vim.keymap.set(modes, lhs, function()
		local ok, opencode = pcall(require, "opencode")
		if not ok then
			-- Surface a gentle warning instead of throwing when the plugin is missing.
			vim.notify("opencode.nvim is unavailable", vim.log.levels.WARN)
			return
		end

		handler(opencode)
	end, { desc = desc, silent = true })
end

map_opencode({ "n", "x" }, "<leader>oa", function(opencode)
	opencode.ask("@this: ", { submit = true })
end, "Ask opencode about context")

map_opencode({ "n", "x" }, "<leader>oo", function(opencode)
	opencode.select()
end, "Open opencode actions")

map_opencode("n", "<leader>ot", function(opencode)
	opencode.toggle()
end, "Toggle opencode panel")

-- vim.keymap.set("n", "<leader>cc", "<cmd>ClaudeCode<CR>", { desc = "Toggle Claude Code" })

function M.apply_lsp_keymaps(opts)
	opts = opts or {}

	local function map(mode, lhs, rhs, desc)
		local map_opts = vim.tbl_extend("force", opts, { desc = desc })
		vim.keymap.set(mode, lhs, rhs, map_opts)
	end

	map("n", "K", vim.lsp.buf.hover, "Hover documentation")
	map("n", "gd", vim.lsp.buf.definition, "Go to definition")
	map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
	map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
	map("n", "go", vim.lsp.buf.type_definition, "Go to type definition")
	map("n", "gr", vim.lsp.buf.references, "Find references")
	map("n", "gs", vim.lsp.buf.signature_help, "Signature help")
	map("n", "<F2>", vim.lsp.buf.rename, "Rename symbol")
	vim.keymap.set({ "n", "x" }, "<F3>", function()
		vim.lsp.buf.format({ async = true })
	end, vim.tbl_extend("force", opts, { desc = "Format buffer" }))
	map("n", "<F4>", vim.lsp.buf.code_action, "Code action")
end

return M
