-- Health check module for custom config
-- Run with :checkhealth custom

local M = {}

function M.check()
    vim.health.start("custom config")

    -- Check Neovim version
    if vim.fn.has("nvim-0.12") == 1 then
        vim.health.ok("Neovim 0.12+ detected")
    elseif vim.fn.has("nvim-0.11") == 1 then
        vim.health.warn("Neovim 0.11 detected - pinned nvim-treesitter now requires 0.12+")
    else
        vim.health.error("Neovim 0.12+ is required (native LSP workflow and current nvim-treesitter)")
    end

    -- Check required CLI tools
    vim.health.start("Required CLI tools")

    local required_tools = {
        { "git", "Version control" },
        { "rg", "Ripgrep for fast searching" },
        -- nvim-treesitter's main branch shells out to `tree-sitter build`;
        -- without it every parser install fails silently.
        { "tree-sitter", "Tree-sitter CLI, required to build parsers (brew install tree-sitter-cli)" },
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
        { "rustfmt", "Rust formatter" },
        { "dotnet-csharpier", "C# formatter" },
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

    -- Check that parsers were actually installed. An empty parser dir means
    -- treesitter highlighting silently falls back to Neovim's 7 bundled
    -- parsers, which is easy to miss because the FileType hook pcalls start().
    vim.health.start("Tree-sitter parsers")

    local ok_ts, treesitter = pcall(require, "nvim-treesitter")
    if not ok_ts then
        vim.health.warn("nvim-treesitter is not loaded")
    else
        local installed = treesitter.get_installed("parsers")
        if #installed == 0 then
            vim.health.error("No Tree-sitter parsers installed; highlighting is limited to bundled languages")
            vim.health.info("Install the CLI (brew install tree-sitter-cli), then run :TSInstallDefaults")
        else
            vim.health.ok(string.format("%d Tree-sitter parser(s) installed", #installed))
            vim.health.info("Run :TSMissing to list configured parsers that are absent")
        end
    end

    -- Check tree-sitter cache ownership to prevent EACCES during parser updates
    vim.health.start("Tree-sitter cache permissions")

    local uv = vim.uv or vim.loop
    local cache_dir = vim.fn.stdpath("cache")
    local current_uid = uv.getuid and uv.getuid() or nil
    local has_permission_issue = false

    for entry, entry_type in vim.fs.dir(cache_dir) do
        if entry_type == "directory" and entry:match("^tree%-sitter%-.+") and not entry:match("%-tmp$") then
            local full_path = cache_dir .. "/" .. entry
            local stat = uv.fs_stat(full_path)

            if stat and current_uid and stat.uid ~= current_uid then
                has_permission_issue = true
                vim.health.warn("Owned by different user: " .. full_path)
            end
        end
    end

    if has_permission_issue then
        local user = vim.fn.system({ "id", "-un" }):gsub("\n", "")
        local group = vim.fn.system({ "id", "-gn" }):gsub("\n", "")
        vim.health.info("Fix with: sudo chown -R " .. user .. ":" .. group .. " " .. cache_dir .. "/tree-sitter-*")
        vim.health.info("Then remove temp dirs: rm -rf " .. cache_dir .. "/tree-sitter-*-tmp")
    else
        vim.health.ok("Tree-sitter cache ownership looks correct")
    end
end

return M
