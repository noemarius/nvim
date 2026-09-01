-- Treesitter syntax highlighting and parsing
local ensure_installed = {
    "bash",
    "c",
    "c_sharp",
    "css",
    "diff",
    "dockerfile",
    "git_config",
    "gitcommit",
    "gitignore",
    "go",
    "gomod",
    "html",
    "javascript",
    "json",
    "jsonc",
    "lua",
    "luadoc",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    "regex",
    "rust",
    "toml",
    "tsx",
    "typescript",
    "typst",
    "vim",
    "vimdoc",
    "yaml",
}

-- The pinned `main` branch shells out to `tree-sitter build` for every parser,
-- so without the CLI on PATH nothing can be installed and every failure is
-- silent (the FileType hook below pcalls treesitter.start).
local function has_tree_sitter_cli()
    if vim.fn.executable("tree-sitter") == 1 then
        return true
    end

    vim.notify(
        "tree-sitter CLI not found; parsers cannot be built.\nInstall it with: brew install tree-sitter",
        vim.log.levels.ERROR
    )
    return false
end

-- install()/update() are async. Callers in script contexts (lazy.nvim's build
-- step, a user command) must wait() or the job is abandoned mid-flight.
local install_timeout_ms = 300000

local function install_parsers()
    if not has_tree_sitter_cli() then
        return
    end

    local treesitter = require("nvim-treesitter")

    local ok_install, install_err = pcall(function()
        treesitter.install(ensure_installed):wait(install_timeout_ms)
    end)
    if not ok_install then
        vim.notify("Tree-sitter parser install failed: " .. tostring(install_err), vim.log.levels.ERROR)
        return
    end

    local ok_update, update_err = pcall(function()
        treesitter.update():wait(install_timeout_ms)
    end)
    if not ok_update then
        vim.notify("Tree-sitter parser update failed: " .. tostring(update_err), vim.log.levels.WARN)
    end
end

local function setup_treesitter()
    local ok, treesitter = pcall(require, "nvim-treesitter")
    if not ok then
        vim.notify("nvim-treesitter not available", vim.log.levels.WARN)
        return
    end

    treesitter.setup({})

    local treesitter_group = vim.api.nvim_create_augroup("custom_treesitter_start", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = treesitter_group,
        pattern = "*",
        callback = function(args)
            pcall(vim.treesitter.start, args.buf)
        end,
    })

    vim.api.nvim_create_user_command("TSInstallDefaults", install_parsers, {
        desc = "Install configured default Tree-sitter parsers",
    })

    vim.api.nvim_create_user_command("TSMissing", function()
        local installed = {}
        for _, lang in ipairs(treesitter.get_installed("parsers")) do
            installed[lang] = true
        end

        local missing = {}
        for _, lang in ipairs(ensure_installed) do
            if not installed[lang] then
                table.insert(missing, lang)
            end
        end

        if #missing == 0 then
            vim.notify("All configured Tree-sitter parsers are installed", vim.log.levels.INFO)
            return
        end

        vim.notify(
            string.format("Missing %d parser(s): %s\nRun :TSInstallDefaults", #missing, table.concat(missing, ", ")),
            vim.log.levels.WARN
        )
    end, {
        desc = "Report configured Tree-sitter parsers that are not installed",
    })
end

return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = install_parsers,
        lazy = false,
        config = setup_treesitter,
    },

    -- Treesitter context (shows function/class context at top)
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = "VeryLazy",
        opts = {
            max_lines = 3,
            trim_scope = "outer",
        },
    },
}
