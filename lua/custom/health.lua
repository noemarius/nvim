-- Health check module for custom config
-- Run with :checkhealth custom

local M = {}

function M.check()
    vim.health.start("custom config")

    -- Check Neovim version
    if vim.fn.has("nvim-0.11") == 1 then
        vim.health.ok("Neovim 0.11+ detected")
    elseif vim.fn.has("nvim-0.10") == 1 then
        vim.health.warn("Neovim 0.10 detected - some features may be limited")
    else
        vim.health.error("Neovim 0.11+ is required for full functionality")
    end

    -- Check required CLI tools
    vim.health.start("Required CLI tools")

    local required_tools = {
        { "git", "Version control" },
        { "rg", "Ripgrep for fast searching" },
    }

    for _, tool in ipairs(required_tools) do
        if vim.fn.executable(tool[1]) == 1 then
            vim.health.ok(tool[1] .. " installed (" .. tool[2] .. ")")
        else
            vim.health.error(tool[1] .. " not found (" .. tool[2] .. ")")
        end
    end

    -- Check optional CLI tools
    vim.health.start("Optional CLI tools")

    local optional_tools = {
        { "fd", "Fast file finder for Telescope" },
        { "stylua", "Lua formatter" },
        { "prettier", "JS/TS/JSON/HTML/CSS formatter" },
        { "ruff", "Fast Python formatter/linter" },
        { "black", "Python formatter (fallback)" },
        { "tmux", "Terminal multiplexer integration" },
    }

    for _, tool in ipairs(optional_tools) do
        if vim.fn.executable(tool[1]) == 1 then
            vim.health.ok(tool[1] .. " installed (" .. tool[2] .. ")")
        else
            vim.health.warn(tool[1] .. " not found (" .. tool[2] .. ")")
        end
    end

    -- Check lazy.nvim
    vim.health.start("Plugin manager")

    local lazy_ok = pcall(require, "lazy")
    if lazy_ok then
        vim.health.ok("lazy.nvim is installed and loaded")
    else
        vim.health.error("lazy.nvim not found")
    end

    -- Check critical plugins
    vim.health.start("Critical plugins")

    local critical_plugins = {
        "telescope",
        "nvim-treesitter",
        "mason",
        "blink.cmp",
    }

    for _, plugin in ipairs(critical_plugins) do
        local ok = pcall(require, plugin)
        if ok then
            vim.health.ok(plugin .. " is available")
        else
            vim.health.warn(plugin .. " is not loaded (may be lazy-loaded)")
        end
    end

    -- Check LSP
    vim.health.start("LSP configuration")

    if vim.lsp and vim.lsp.config and vim.lsp.enable then
        vim.health.ok("Native LSP API available (vim.lsp.config/enable)")
    else
        vim.health.error("Native LSP API not available - update Neovim to 0.11+")
    end

    -- Check directories
    vim.health.start("Configuration paths")

    local undodir = os.getenv("HOME") .. "/.vim/undodir"
    if vim.fn.isdirectory(undodir) == 1 then
        vim.health.ok("Undo directory exists: " .. undodir)
    else
        vim.health.warn("Undo directory does not exist: " .. undodir)
        vim.health.info("Create with: mkdir -p " .. undodir)
    end
end

return M
