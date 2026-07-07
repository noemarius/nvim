-- Treesitter syntax highlighting and parsing
local ensure_installed = {
    "bash",
    "c",
    "css",
    "go",
    "html",
    "javascript",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    "rust",
    "typescript",
    "typst",
    "vim",
    "vimdoc",
    "yaml",
}

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

    vim.api.nvim_create_user_command("TSInstallDefaults", function()
        local ok_install, install_err = pcall(treesitter.install, ensure_installed)
        if not ok_install then
            vim.notify("TSInstallDefaults failed: " .. tostring(install_err), vim.log.levels.WARN)
        end
    end, {
        desc = "Install configured default Tree-sitter parsers",
    })
end

return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = function()
            -- Keep parser updates and default installs in the plugin lifecycle,
            -- not on every editor startup.
            vim.cmd("TSUpdate")
            vim.cmd("TSInstall " .. table.concat(ensure_installed, " "))
        end,
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
