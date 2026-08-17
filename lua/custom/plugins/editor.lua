-- Core editing plugins: surround, autopairs, comment, indent guides
return {
    -- Surround selections with quotes, brackets, etc.
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup()
        end,
    },

    -- Auto-close pairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({})
        end,
    },

    -- Smart commenting
    {
        "numToStr/Comment.nvim",
        event = "VeryLazy",
        config = function()
            local comment = require("Comment")
            local comment_ft = require("Comment.ft")
            local calculate = comment_ft.calculate

            -- Comment.nvim assumes get_parser() throws when unavailable; Neovim 0.12 can return nil.
            comment_ft.calculate = function(ctx)
                local ok_parser, parser = pcall(vim.treesitter.get_parser, vim.api.nvim_get_current_buf())
                if not ok_parser or not parser then
                    return comment_ft.get(vim.bo.filetype, ctx.ctype)
                end

                local ok_cstr, cstr = pcall(calculate, ctx)
                if ok_cstr then
                    return cstr
                end

                return comment_ft.get(vim.bo.filetype, ctx.ctype)
            end

            comment.setup()
        end,
    },

    -- Indent guides
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = "VeryLazy",
        opts = {
            indent = {
                char = "│",
            },
            scope = {
                enabled = true,
                show_start = false,
                show_end = false,
                char = "▎",
            },
        },
    },

    -- Auto-close HTML/JSX tags
    {
        "windwp/nvim-ts-autotag",
        event = "InsertEnter",
        opts = {
            opts = {
                enable_close = true,
                enable_rename = true,
                enable_close_on_slash = false,
            },
        },
    },

    -- Refactoring support
    {
        "theprimeagen/refactoring.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        keys = {
            {
                "<leader>re",
                mode = "x",
                function()
                    require("refactoring").refactor("Extract Function")
                end,
                desc = "[Refactor] Extract function",
            },
            {
                "<leader>rf",
                mode = "x",
                function()
                    require("refactoring").refactor("Extract Function To File")
                end,
                desc = "[Refactor] Extract to file",
            },
            {
                "<leader>rv",
                mode = "x",
                function()
                    require("refactoring").refactor("Extract Variable")
                end,
                desc = "[Refactor] Extract variable",
            },
            {
                "<leader>ri",
                mode = { "n", "x" },
                function()
                    require("refactoring").refactor("Inline Variable")
                end,
                desc = "[Refactor] Inline variable",
            },
        },
        config = function()
            require("refactoring").setup({})
        end,
    },

    -- Hide sensitive data
    {
        "laytan/cloak.nvim",
        event = "VeryLazy",
    },

    -- Window picker
    {
        "s1n7ax/nvim-window-picker",
        version = "2.*",
        event = "VeryLazy",
        config = function()
            require("window-picker").setup()
        end,
    },
}
