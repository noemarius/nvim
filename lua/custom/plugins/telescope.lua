-- Telescope fuzzy finder
return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },
        },
        cmd = "Telescope",
        keys = {
            { "<leader>tf", function() require("telescope.builtin").find_files() end, desc = "[Telescope] Find files" },
            { "<leader>tg", function() require("telescope.builtin").git_files() end, desc = "[Telescope] Git files" },
            { "<leader>ti", function() require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") }) end, desc = "[Telescope] Grep input" },
            { "<leader>tl", function() require("telescope.builtin").live_grep() end, desc = "[Telescope] Live grep" },
            { "<leader>tb", function() require("telescope.builtin").buffers() end, desc = "[Telescope] Buffers" },
            { "<leader>th", function() require("telescope.builtin").help_tags() end, desc = "[Telescope] Help tags" },
            { "<leader>tr", function() require("telescope.builtin").resume() end, desc = "[Telescope] Resume last" },
            { "<leader>td", function() require("telescope.builtin").diagnostics() end, desc = "[Telescope] Diagnostics" },
            { "<leader>ts", function() require("telescope.builtin").lsp_document_symbols() end, desc = "[Telescope] Document symbols" },
            { "<leader>tw", function() require("telescope.builtin").lsp_workspace_symbols() end, desc = "[Telescope] Workspace symbols" },
            { "<leader>tm", function() require("telescope.builtin").keymaps() end, desc = "[Telescope] Search keymaps" },
        },
        opts = {
            pickers = {
                find_files = {
                    hidden = true,
                },
            },
            defaults = {
                file_ignore_patterns = {
                    "node_modules",
                    ".git",
                    ".keep",
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
            },
        },
        config = function(_, opts)
            local telescope = require("telescope")
            telescope.setup(opts)
            pcall(telescope.load_extension, "fzf")
        end,
    },
}
