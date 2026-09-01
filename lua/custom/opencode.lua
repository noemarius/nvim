-- Opencode lifecycle: discover the server port from the tmux session
-- environment and (re)attach opencode.nvim to it, debounced on focus changes.
local api = vim.api
local uv = vim.uv or vim.loop

local opencode_group = api.nvim_create_augroup("custom_opencode", { clear = true })
local opencode_focus_delay_ms = 350
local opencode_focus_check_interval_ms = 3000
local opencode_focus_timer = uv and uv.new_timer and uv.new_timer() or nil
local opencode_focus_last_check_ms = 0
local opencode_focus_last_session = nil
local opencode_focus_last_port = nil
local opencode_focus_attach_in_progress = false

local function monotonic_time_ms()
    if not uv or not uv.hrtime then
        return 0
    end

    return math.floor(uv.hrtime() / 1000000)
end

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

local function opencode_tmux_session_port(callback)
    if not vim.env.TMUX then
        callback(nil, nil)
        return
    end

    if vim.fn.executable("tmux") ~= 1 then
        callback(nil, nil)
        return
    end

    vim.system({ "tmux", "display-message", "-p", "#{session_name}" }, { text = true }, function(session)
        if session.code ~= 0 then
            vim.schedule(function()
                callback(nil, nil)
            end)
            return
        end

        local session_name = vim.trim(session.stdout or "")
        if session_name == "" then
            vim.schedule(function()
                callback(nil, nil)
            end)
            return
        end

        vim.system({ "tmux", "show-environment", "-t", session_name, "OPENCODE_PORT" }, { text = true }, function(env)
            local port = nil
            if env.code == 0 then
                local line = vim.trim(env.stdout or "")
                port = tonumber(line:match("^OPENCODE_PORT=(%d+)$"))
            end

            vim.schedule(function()
                callback(port, session_name)
            end)
        end)
    end)
end

local function opencode_connect(port)
    if not port then
        return
    end

    local ok_config, config = pcall(require, "opencode.config")
    if not ok_config then
        return
    end

    vim.g.opencode_opts = vim.tbl_deep_extend("force", vim.g.opencode_opts or {}, { server = { port = port } })
    config.opts.server = config.opts.server or {}
    config.opts.server.port = port

    local ok_server, server = pcall(require, "opencode.server")
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

local function opencode_attach_tmux()
    local port = opencode_tmux_port()
    if not port then
        return
    end

    opencode_connect(port)
end

local function should_skip_focus_attach()
    if not vim.env.TMUX then
        return true
    end

    if vim.fn.executable("tmux") ~= 1 then
        return true
    end

    if not package.loaded["opencode"] and not package.loaded["opencode.config"] then
        return true
    end

    return false
end

local function maybe_attach_opencode_on_focus()
    if should_skip_focus_attach() then
        return
    end

    local now = monotonic_time_ms()
    if
        opencode_focus_last_check_ms > 0
        and now > 0
        and (now - opencode_focus_last_check_ms) < opencode_focus_check_interval_ms
    then
        return
    end

    if opencode_focus_attach_in_progress then
        return
    end

    opencode_focus_attach_in_progress = true
    opencode_tmux_session_port(function(port, session_name)
        opencode_focus_attach_in_progress = false
        opencode_focus_last_check_ms = monotonic_time_ms()

        if not port or not session_name then
            return
        end

        local current_port = nil
        local ok_config, config = pcall(require, "opencode.config")
        if ok_config and config and config.opts and config.opts.server then
            current_port = tonumber(config.opts.server.port)
        end

        if current_port == nil and vim.g.opencode_opts and vim.g.opencode_opts.server then
            current_port = tonumber(vim.g.opencode_opts.server.port)
        end

        if
            session_name == opencode_focus_last_session
            and port == opencode_focus_last_port
            and current_port == port
        then
            return
        end

        opencode_focus_last_session = session_name
        opencode_focus_last_port = port

        if current_port == port then
            return
        end

        opencode_connect(port)
    end)
end

local function schedule_opencode_attach_tmux()
    if not opencode_focus_timer then
        maybe_attach_opencode_on_focus()
        return
    end

    -- Debounce focus-triggered attaches to avoid repeated tmux queries while switching panes.
    opencode_focus_timer:stop()
    opencode_focus_timer:start(opencode_focus_delay_ms, 0, vim.schedule_wrap(maybe_attach_opencode_on_focus))
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
