local remap = require("nma.remap")

vim.opt.signcolumn = "yes"

if not (vim.lsp and vim.lsp.config and vim.lsp.enable) then
	vim.notify("Neovim v0.11+ is required for the built-in LSP workflow", vim.log.levels.ERROR)
	return
end

local servers = { "lua_ls", "gopls", "eslint", "tailwindcss", "rust_analyzer" }

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp_caps, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp_caps then
	capabilities = vim.tbl_deep_extend("force", capabilities, cmp_nvim_lsp.default_capabilities())
else
	vim.notify("cmp-nvim-lsp not available; completion capabilities will be limited", vim.log.levels.WARN)
end

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Apply custom LSP keymaps",
	callback = function(event)
		remap.apply_lsp_keymaps({ buffer = event.buf })
	end,
})

local function setup_mason()
	local ok_mason, mason = pcall(require, "mason")
	if ok_mason then
		mason.setup({})
	else
		vim.notify("mason.nvim is not available", vim.log.levels.WARN)
	end

	local ok_mason_lsp, mason_lspconfig = pcall(require, "mason-lspconfig")
	if ok_mason_lsp then
		mason_lspconfig.setup({
			ensure_installed = servers,
		})
	else
		vim.notify("mason-lspconfig.nvim is not available", vim.log.levels.WARN)
	end
end

local function extend_server(name, opts)
	opts = opts or {}
	opts.capabilities = vim.tbl_deep_extend("force", {}, capabilities, opts.capabilities or {})

	vim.lsp.config(name, opts)
	local ok, err = pcall(vim.lsp.enable, name)
	if not ok then
		vim.notify(string.format("Failed to enable LSP '%s': %s", name, err), vim.log.levels.WARN)
	end
end

setup_mason()

extend_server("lua_ls", {
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				checkThirdParty = false,
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
})

for _, server in ipairs(servers) do
	if server ~= "lua_ls" then
		extend_server(server)
	end
end

local ok_cmp, cmp = pcall(require, "cmp")
if not ok_cmp then
	vim.notify("nvim-cmp not available; skipping completion setup", vim.log.levels.WARN)
	return
end

local select_behavior = { behavior = cmp.SelectBehavior.Select }

local function has_words_before()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	if col == 0 then
		return false
	end
	local text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1] or ""
	return text:sub(col, col):match("%s") == nil
end

local function snippet_active(direction)
	if not vim.snippet or not vim.snippet.active then
		return false
	end
	return vim.snippet.active({ direction = direction })
end

local function snippet_jump(direction)
	if not vim.snippet or not vim.snippet.jump then
		return false
	end
	vim.snippet.jump(direction)
	return true
end

cmp.setup({
	sources = {
		{ name = "nvim_lsp" },
	},
	snippet = {
		expand = function(args)
			if vim.snippet and vim.snippet.expand then
				vim.snippet.expand(args.body)
			else
				vim.notify("vim.snippet is unavailable; update Neovim to v0.10+", vim.log.levels.WARN)
			end
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item(select_behavior)
			elseif snippet_active(1) then
				snippet_jump(1)
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item(select_behavior)
			elseif snippet_active(-1) then
				snippet_jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
})
