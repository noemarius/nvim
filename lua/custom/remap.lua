local M = {}

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "[Netrw] Open file explorer" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "[Edit] Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "[Edit] Move selection up" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "[Edit] Join lines (cursor stays)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "[Navigation] Scroll down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "[Navigation] Scroll up (centered)" })

vim.keymap.set(
	"n",
	"<leader>cd",
	'<cmd>lua vim.diagnostic.open_float()<CR><cmd>lua vim.diagnostic.open_float()<CR>ggVG"+Y<CR>',
	{ desc = "[Diagnostic] Copy to clipboard" }
)

vim.keymap.set("n", "<leader>/", ":nohl<CR>", { desc = "[Search] Clear highlight" })
vim.keymap.set("x", "<leader>p", [['_dP]], { desc = "[Edit] Paste without overwriting register" })

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "[Clipboard] Yank selection" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "[Clipboard] Yank line" })

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "[Edit] Delete to black hole register" })


vim.keymap.set("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "[Session] Force quit all" })
vim.keymap.set("n", "<leader>q", "<cmd>qa<CR>", { desc = "[Session] Quit all" })

vim.keymap.set("n", "Q", "<nop>", { desc = "[Edit] Disable Ex mode" })
vim.keymap.set("n", "<leader>f", "<cmd>Format<CR>", { desc = "[Format] Format buffer" })

vim.keymap.set("n", "]q", "<cmd>cnext<CR>zz", { desc = "[Quickfix] Go to next" })
vim.keymap.set("n", "[q", "<cmd>cprev<CR>zz", { desc = "[Quickfix] Go to previous" })
vim.keymap.set("n", "]l", "<cmd>lnext<CR>zz", { desc = "[Loclist] Go to next" })
vim.keymap.set("n", "[l", "<cmd>lprev<CR>zz", { desc = "[Loclist] Go to previous" })

-- Optional window management helpers
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "[Window] Vertical split" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "[Window] Horizontal split" })
vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "[Window] Balance all" })
vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "[Window] Go left" })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "[Window] Go down" })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "[Window] Go up" })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "[Window] Go right" })

vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "[Search] Replace word under cursor" }
)
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "[File] Make executable" })

vim.keymap.set(
	"n",
	"<leader>ge",
	"oif err != nil {<CR>}<Esc>Oreturn nil, err<Esc>",
	{ desc = "[Snippet] Go error handling" }
)

vim.keymap.set("n", "<leader>vm", "<cmd>e ~/.config/nvim/lua/custom/remap.lua<CR>", { desc = "[Config] Edit remap.lua" })
vim.keymap.set("n", "<leader>vp", "<cmd>e ~/.config/nvim/lua/custom/plugins/<CR>", { desc = "[Config] Edit plugins" })

vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
	vim.notify("Sourced current file")
end, { desc = "[Config] Source current file" })

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
end, "[Opencode] Ask about context")

map_opencode({ "n", "x" }, "<leader>oo", function(opencode)
	opencode.select()
end, "[Opencode] Select action")

-- Toggle opencode panel (works in both normal and terminal mode)
vim.keymap.set({ "n", "t" }, "<C-.>", function()
	local ok, opencode = pcall(require, "opencode")
	if not ok then
		vim.notify("opencode.nvim is unavailable", vim.log.levels.WARN)
		return
	end
	opencode.toggle()
end, { desc = "[Opencode] Toggle panel", silent = true })

-- Exit terminal-mode without sending Escape to the TUI (won't interrupt agent flows)
vim.keymap.set("t", [[<C-\><C-\>]], [[<C-\><C-n><C-w>p]], { desc = "[Terminal] Exit to normal mode" })

function M.apply_lsp_keymaps(opts)
	opts = opts or {}

	local function map(mode, lhs, rhs, desc)
		local map_opts = vim.tbl_extend("force", opts, { desc = desc })
		vim.keymap.set(mode, lhs, rhs, map_opts)
	end

	map("n", "K", vim.lsp.buf.hover, "[LSP] Hover documentation")
	map("n", "gd", vim.lsp.buf.definition, "[LSP] Go to definition")
	map("n", "gD", vim.lsp.buf.declaration, "[LSP] Go to declaration")
	map("n", "gi", vim.lsp.buf.implementation, "[LSP] Go to implementation")
	map("n", "go", vim.lsp.buf.type_definition, "[LSP] Go to type definition")
	map("n", "gr", vim.lsp.buf.references, "[LSP] Find references")
	map("n", "gs", vim.lsp.buf.signature_help, "[LSP] Signature help")
	map("n", "<F2>", vim.lsp.buf.rename, "[LSP] Rename symbol")
	vim.keymap.set({ "n", "x" }, "<F3>", function()
		vim.lsp.buf.format({ async = true })
	end, vim.tbl_extend("force", opts, { desc = "[LSP] Format buffer" }))
	map("n", "<F4>", vim.lsp.buf.code_action, "[LSP] Code action")
end

return M
