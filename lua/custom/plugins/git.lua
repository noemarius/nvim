-- Git integration plugins
return {
    -- Git commands
    {
        "tpope/vim-fugitive",
        cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
        keys = {
            { "<leader>gs", vim.cmd.Git, desc = "[Git] Fugitive status" },
        },
    },

    -- Git signs in gutter
    {
        "lewis6991/gitsigns.nvim",
        event = "VeryLazy",
        opts = {
            signs = {
                add = { text = "│" },
                change = { text = "│" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
            linehl = true,
            numhl = true,
            on_attach = function(bufnr)
                local gs = require("gitsigns")

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map("n", "<leader>hn", function()
                    gs.nav_hunk("next")
                end, { desc = "[Gitsigns] Next hunk" })
                map("n", "<leader>hp", function()
                    gs.nav_hunk("prev")
                end, { desc = "[Gitsigns] Previous hunk" })

                -- Actions
                map("n", "<leader>hs", gs.stage_hunk, { desc = "[Gitsigns] Stage hunk" })
                map("n", "<leader>hr", gs.reset_hunk, { desc = "[Gitsigns] Reset hunk" })
                map("n", "<leader>hv", gs.preview_hunk, { desc = "[Gitsigns] Preview hunk" })
                map("n", "<leader>hb", function()
                    gs.blame_line({ full = true })
                end, { desc = "[Gitsigns] Blame line (full)" })
            end,
        },
        config = function(_, opts)
            require("gitsigns").setup(opts)
            -- Subtle line highlights (lower opacity effect via darker bg colors)
            vim.api.nvim_set_hl(0, "GitSignsAddLn", { bg = "#1a2a1a" })
            vim.api.nvim_set_hl(0, "GitSignsChangeLn", { bg = "#1a1a2a" })
            vim.api.nvim_set_hl(0, "GitSignsDeleteLn", { bg = "#2a1a1a" })
        end,
    },
}
