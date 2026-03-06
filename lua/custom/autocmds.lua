local vim = vim
local api = vim.api
local uv = vim.uv or vim.loop

local function set_indent(bufnr, width)
	local buffer = vim.bo[bufnr]
	buffer.shiftwidth = width
	buffer.tabstop = width
	buffer.softtabstop = width
	buffer.expandtab = true
end

local indent_group = api.nvim_create_augroup("custom_indent", { clear = true })

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

local netrw_group = api.nvim_create_augroup("custom_netrw", { clear = true })

api.nvim_create_autocmd("FileType", {
	group = netrw_group,
	pattern = "netrw",
	callback = function(args)
		-- Netrw sets buffer-local C-h/j/k/l mappings; clear them for tmux navigation.
		pcall(vim.keymap.del, "n", "<C-h>", { buffer = args.buf })
		pcall(vim.keymap.del, "n", "<C-j>", { buffer = args.buf })
		pcall(vim.keymap.del, "n", "<C-k>", { buffer = args.buf })
		pcall(vim.keymap.del, "n", "<C-l>", { buffer = args.buf })
	end,
})

-- Open opencode panel on startup if .opencode config exists in cwd
local opencode_group = api.nvim_create_augroup("custom_opencode", { clear = true })
local opencode_focus_delay_ms = 750
local opencode_focus_timer = uv and uv.new_timer and uv.new_timer() or nil

local function opencode_tmux_port()
	if not vim.env.TMUX then
		return nil
	end

	if vim.fn.executable("tmux") ~= 1 then
		return nil
	end

	local session = vim.system({ "tmux", "display-message", "-p", "#{session_name}" }, { text = true }):wait()
	if session.code ~= 0 then
		return nil
	end

	local name = vim.trim(session.stdout or "")
	if name == "" then
		return nil
	end

	local env = vim.system({ "tmux", "show-environment", "-t", name, "OPENCODE_PORT" }, { text = true }):wait()
	if env.code ~= 0 then
		return nil
	end

	local line = vim.trim(env.stdout or "")
	local port = tonumber(line:match("^OPENCODE_PORT=(%d+)$"))
	return port
end

local function opencode_attach_tmux()
	local port = opencode_tmux_port()
	if not port then
		return
	end

	local ok_config, config = pcall(require, "opencode.config")
	if not ok_config then
		return
	end

	vim.g.opencode_opts = vim.tbl_deep_extend("force", vim.g.opencode_opts or {}, { port = port })
	config.opts.port = port

	local ok_server, server = pcall(require, "opencode.cli.server")
	if not ok_server then
		return
	end

	local ok_events, events = pcall(require, "opencode.events")
	if ok_events and events and events.disconnect then
		events.disconnect()
	end

	server
		.get(false)
		:next(function(found)
			local ok_connect, connect_events = pcall(require, "opencode.events")
			if ok_connect and connect_events then
				connect_events.connect(found)
			end
		end)
		:catch(function(err)
			if not err then
				return
			end

			local msg = tostring(err)
			if msg == "" then
				return
			end

			if msg:find("No `opencode` processes found", 1, true) then
				return
			end

			if msg:find("No `opencode` servers found", 1, true) then
				return
			end

			vim.notify("Opencode attach failed: " .. msg, vim.log.levels.WARN)
		end)
end

local function schedule_opencode_attach_tmux()
	if not opencode_focus_timer then
		opencode_attach_tmux()
		return
	end

	-- Debounce focus-triggered attaches to avoid repeated tmux queries while switching panes.
	opencode_focus_timer:stop()
	opencode_focus_timer:start(opencode_focus_delay_ms, 0, vim.schedule_wrap(opencode_attach_tmux))
end

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

api.nvim_create_user_command("OpencodeAttachTmux", opencode_attach_tmux, {
	desc = "Attach opencode using tmux session port",
})

api.nvim_create_autocmd("VimEnter", {
	group = opencode_group,
	desc = "Attach opencode using tmux session port",
	callback = opencode_attach_tmux,
})

api.nvim_create_autocmd("FocusGained", {
	group = opencode_group,
	desc = "Debounced opencode tmux attach on focus",
	callback = schedule_opencode_attach_tmux,
})

api.nvim_create_autocmd("VimLeavePre", {
	group = opencode_group,
	desc = "Clean up debounced opencode focus timer",
	callback = function()
		if not opencode_focus_timer then
			return
		end

		opencode_focus_timer:stop()
		opencode_focus_timer:close()
		opencode_focus_timer = nil
	end,
})
