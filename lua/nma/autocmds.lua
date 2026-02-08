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

local function opencode_cleanup_cwd()
	local cwd = vim.fn.getcwd()
	local pgrep = vim.system({ "pgrep", "-f", "opencode.*--port" }, { text = true }):wait()
	if pgrep.code ~= 0 or pgrep.stdout == "" then
		vim.notify("No opencode servers found", vim.log.levels.INFO)
		return
	end

	local pids = {}
	for line in pgrep.stdout:gmatch("[^\r\n]+") do
		local pid = tonumber(line)
		if pid then
			table.insert(pids, pid)
		end
	end

	local matches = {}
	for _, pid in ipairs(pids) do
		local lsof = vim.system({ "lsof", "-a", "-p", tostring(pid), "-d", "cwd", "-Fn" }, { text = true }):wait()
		if lsof.code == 0 then
			for line in lsof.stdout:gmatch("[^\r\n]+") do
				if vim.startswith(line, "n") then
					local proc_cwd = line:sub(2)
					if proc_cwd == cwd then
						table.insert(matches, pid)
					end
					break
				end
			end
		end
	end

	if #matches == 0 then
		vim.notify("No opencode servers found for cwd", vim.log.levels.INFO)
		return
	end

	local choice = vim.fn.confirm(string.format("Kill %d opencode server(s) in %s?", #matches, cwd), "&Yes\n&No", 2)
	if choice ~= 1 then
		return
	end

	for _, pid in ipairs(matches) do
		vim.system({ "kill", "-TERM", tostring(pid) })
	end
	vim.notify(string.format("Killed %d opencode server(s)", #matches), vim.log.levels.INFO)
end

api.nvim_create_user_command("OpencodeCleanupCwd", opencode_cleanup_cwd, {
	desc = "Kill opencode servers in current cwd",
})

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

api.nvim_create_autocmd("VimLeavePre", {
	group = opencode_group,
	desc = "Stop opencode provider on exit",
	callback = function()
		local ok_provider, provider = pcall(require, "opencode.provider")
		if ok_provider and provider and provider.stop then
			pcall(provider.stop)
		end
	end,
})
