-- Format-on-save for all filetypes
-- Dispatches to appropriate formatter based on filetype

local format_group = vim.api.nvim_create_augroup("NmaFormat", { clear = true })

-- Track warnings to avoid spamming
local warned = {}

local function warn_once(key, msg)
    if not warned[key] then
        vim.notify(msg, vim.log.levels.WARN)
        warned[key] = true
    end
end

-- Run a CLI formatter and return formatted content or nil on error
local function run_formatter(cmd, args, source, filepath)
    local full_args = vim.list_extend({ cmd }, args)
    local output = vim.fn.system(full_args, source)

    if vim.v.shell_error ~= 0 then
        vim.notify(cmd .. " failed: " .. output, vim.log.levels.ERROR)
        return nil
    end

    return output
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

    -- Python: black
    python = function(bufnr, filepath, source)
        if vim.fn.executable("black") == 0 then
            warn_once("black", "black not found; install via Mason")
            return nil
        end
        return run_formatter("black", {
            "--quiet",
            "--stdin-filename",
            filepath,
            "-",
        }, source, filepath)
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

    -- Rust: use LSP (rustfmt via rust-analyzer)
    rust = function(bufnr, filepath, source)
        vim.lsp.buf.format({ bufnr = bufnr, async = false })
        return nil -- LSP handles it directly
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
        if client.supports_method("textDocument/formatting") then
            vim.lsp.buf.format({ bufnr = bufnr, async = false })
            return true
        end
    end
    return false
end

-- Main format function
local function format_buffer(event)
    local bufnr = event.buf
    local filepath = vim.api.nvim_buf_get_name(bufnr)

    if filepath == "" then
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
