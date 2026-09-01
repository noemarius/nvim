-- Format-on-save for all filetypes
-- Dispatches to appropriate formatter based on filetype

local format_group = vim.api.nvim_create_augroup("CustomFormat", { clear = true })

-- Track warnings to avoid spamming
local warned = {}
local formatter_timeout_ms = 5000

-- Global toggle for autoformat
vim.g.autoformat_enabled = true

local function warn_once(key, msg)
    if not warned[key] then
        vim.notify(msg, vim.log.levels.WARN)
        warned[key] = true
    end
end

-- Binary file extensions to skip
local binary_extensions = {
    "png",
    "jpg",
    "jpeg",
    "gif",
    "bmp",
    "ico",
    "webp",
    "svg",
    "pdf",
    "doc",
    "docx",
    "xls",
    "xlsx",
    "ppt",
    "pptx",
    "zip",
    "tar",
    "gz",
    "bz2",
    "xz",
    "7z",
    "rar",
    "exe",
    "dll",
    "so",
    "dylib",
    "bin",
    "mp3",
    "mp4",
    "avi",
    "mkv",
    "mov",
    "wav",
    "flac",
    "ttf",
    "otf",
    "woff",
    "woff2",
    "eot",
    "sqlite",
    "db",
}

-- Check if file is binary
local function is_binary(filepath)
    -- Check extension first
    local ext = filepath:match("%.([^%.]+)$")
    if ext and vim.tbl_contains(binary_extensions, ext:lower()) then
        return true
    end

    -- Check for null bytes in first 1024 chars
    local f = io.open(filepath, "rb")
    if f then
        local content = f:read(1024)
        f:close()
        if content and content:find("%z") then
            return true
        end
    end

    return false
end

-- Run a CLI formatter and return formatted content or nil on error
local function run_formatter(cmd, args, source, filepath)
    local full_args = vim.list_extend({ cmd }, vim.deepcopy(args))
    local job = vim.system(full_args, {
        stdin = source,
        text = true,
    })
    local result = job:wait(formatter_timeout_ms)
    -- On timeout, wait() sends SIGKILL and sets code to 124 (see :h vim.system).
    if result.code == 124 then
        warn_once(
            cmd .. "_timeout",
            string.format("%s timed out after %dms; skipped formatting for %s", cmd, formatter_timeout_ms, filepath)
        )
        return nil
    end

    if result.code ~= 0 then
        local error_output = vim.trim(result.stderr ~= "" and result.stderr or result.stdout or "")
        if error_output == "" then
            error_output = string.format("exit code %d", result.code)
        end
        vim.notify(cmd .. " failed: " .. error_output, vim.log.levels.ERROR)
        return nil
    end

    return result.stdout
end

-- Apply formatted content to buffer if different
local function apply_format(bufnr, formatted)
    if not formatted then
        return false
    end

    local lines = vim.split(formatted:gsub("\r\n", "\n"), "\n", { plain = true })
    -- Remove trailing empty line if present (formatters often add one)
    if lines[#lines] == "" then
        table.remove(lines)
    end

    local current = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    -- Check if content changed
    if #lines == #current then
        local identical = true
        for idx = 1, #lines do
            if lines[idx] ~= current[idx] then
                identical = false
                break
            end
        end
        if identical then
            return false
        end
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    return true
end

-- Formatter definitions
local formatters = {
    -- Lua: stylua
    lua = function(bufnr, filepath, source)
        if vim.fn.executable("stylua") == 0 then
            warn_once("stylua", "stylua not found; install via Mason or brew")
            return nil
        end
        return run_formatter("stylua", {
            "--search-parent-directories",
            "--stdin-filepath",
            filepath,
            "-",
        }, source, filepath)
    end,

    -- JavaScript/TypeScript/JSON/HTML/CSS/Markdown: prettier
    javascript = function(bufnr, filepath, source)
        if vim.fn.executable("prettier") == 0 then
            warn_once("prettier", "prettier not found; install via Mason")
            return nil
        end
        return run_formatter("prettier", {
            "--stdin-filepath",
            filepath,
        }, source, filepath)
    end,

    -- Python: ruff (fast) or black (fallback)
    python = function(bufnr, filepath, source)
        if vim.fn.executable("ruff") == 1 then
            return run_formatter("ruff", {
                "format",
                "--stdin-filename",
                filepath,
                "-",
            }, source, filepath)
        elseif vim.fn.executable("black") == 1 then
            return run_formatter("black", {
                "--quiet",
                "--stdin-filename",
                filepath,
                "-",
            }, source, filepath)
        else
            warn_once("python_fmt", "ruff/black not found; install via Mason")
            return nil
        end
    end,

    -- C#: csharpier
    cs = function(bufnr, filepath, source)
        if vim.fn.executable("dotnet-csharpier") == 0 then
            warn_once("csharpier", "csharpier not found; install via Mason")
            return nil
        end
        return run_formatter("dotnet-csharpier", {
            "--write-stdout",
            filepath,
        }, source, filepath)
    end,

    -- Go: use LSP (gofmt via gopls)
    go = function(bufnr, filepath, source)
        vim.lsp.buf.format({ bufnr = bufnr, async = false })
        return nil -- LSP handles it directly
    end,

    -- Rust: rustfmt (works on standalone files; no Cargo project needed)
    rust = function(bufnr, filepath, source)
        if vim.fn.executable("rustfmt") == 0 then
            warn_once("rustfmt", "rustfmt not found; install via rustup or Mason")
            return nil
        end
        return run_formatter("rustfmt", {
            "--emit",
            "stdout",
            "--edition",
            "2024",
        }, source, filepath)
    end,
}

-- Aliases for filetypes that share formatters
formatters.typescript = formatters.javascript
formatters.javascriptreact = formatters.javascript
formatters.typescriptreact = formatters.javascript
formatters.json = formatters.javascript
formatters.jsonc = formatters.javascript
formatters.html = formatters.javascript
formatters.css = formatters.javascript
formatters.scss = formatters.javascript
formatters.less = formatters.javascript
formatters.markdown = formatters.javascript
formatters.yaml = formatters.javascript
formatters.vue = formatters.javascript
formatters.svelte = formatters.javascript

-- Fallback to LSP format for unknown filetypes with LSP attached
local function lsp_fallback(bufnr)
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    for _, client in ipairs(clients) do
        if client:supports_method("textDocument/formatting") then
            vim.lsp.buf.format({ bufnr = bufnr, async = false })
            return true
        end
    end
    return false
end

-- Main format function
local function format_buffer(event)
    -- Check if autoformat is enabled
    if not vim.g.autoformat_enabled then
        return
    end

    local bufnr = event.buf
    local filepath = vim.api.nvim_buf_get_name(bufnr)

    if filepath == "" then
        return
    end

    -- Skip binary files
    if is_binary(filepath) then
        return
    end

    local filetype = vim.bo[bufnr].filetype
    local formatter = formatters[filetype]

    if formatter then
        local source = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
        local formatted = formatter(bufnr, filepath, source)
        if formatted then
            apply_format(bufnr, formatted)
        end
    else
        -- Try LSP fallback for filetypes without explicit formatter
        lsp_fallback(bufnr)
    end
end

-- Create autocmd for format on save
vim.api.nvim_create_autocmd("BufWritePre", {
    group = format_group,
    pattern = "*",
    callback = format_buffer,
})

-- Expose manual format command
vim.api.nvim_create_user_command("Format", function()
    format_buffer({ buf = vim.api.nvim_get_current_buf() })
end, { desc = "Format current buffer" })

-- Toggle autoformat command
vim.api.nvim_create_user_command("FormatToggle", function()
    vim.g.autoformat_enabled = not vim.g.autoformat_enabled
    vim.notify("Autoformat " .. (vim.g.autoformat_enabled and "enabled" or "disabled"))
end, { desc = "Toggle format on save" })
