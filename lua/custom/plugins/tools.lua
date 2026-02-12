-- Utility plugins: harpoon, trouble, undotree, tmux integration
return {
    -- Harpoon 2 for quick file navigation
    {
        "theprimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")
            harpoon:setup({})

            vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "[Harpoon] Add file" })
            vim.keymap.set("n", "<leader>e", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "[Harpoon] Toggle menu" })
            vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "[Harpoon] File 1" })
            vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "[Harpoon] File 2" })
            vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "[Harpoon] File 3" })
            vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "[Harpoon] File 4" })
            vim.keymap.set("n", "<leader>5", function() harpoon:list():select(5) end, { desc = "[Harpoon] File 5" })
            vim.keymap.set("n", "<leader>6", function() harpoon:list():select(6) end, { desc = "[Harpoon] File 6" })
            vim.keymap.set("n", "<leader>7", function() harpoon:list():select(7) end, { desc = "[Harpoon] File 7" })
            vim.keymap.set("n", "<leader>8", function() harpoon:list():select(8) end, { desc = "[Harpoon] File 8" })
            vim.keymap.set("n", "<leader>9", function() harpoon:list():select(9) end, { desc = "[Harpoon] File 9" })

            -- Navigate prev/next
            vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end, { desc = "[Harpoon] Previous file" })
            vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end, { desc = "[Harpoon] Next file" })
        end,
    },

    -- Trouble diagnostics list
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "[Trouble] Toggle diagnostics" },
            { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "[Trouble] Document diagnostics" },
            { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "[Trouble] Quickfix list" },
            { "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "[Trouble] Location list" },
            { "<leader>xr", "<cmd>Trouble lsp_references toggle<CR>", desc = "[Trouble] LSP references" },
        },
        opts = {
            auto_close = true,
            focus = true,
        },
    },

    -- Undotree for undo history visualization
    {
        "mbbill/undotree",
        cmd = "UndotreeToggle",
        keys = {
            { "<leader>u", vim.cmd.UndotreeToggle, desc = "[Undotree] Toggle" },
        },
    },

    -- Tmux integration
    {
        "aserowy/tmux.nvim",
        event = "VeryLazy",
        config = function()
            require("tmux").setup({
                copy_sync = {
                    enable = true,
                    ignore_buffers = { empty = false },
                    redirect_to_clipboard = false,
                    register_offset = 0,
                    sync_clipboard = true,
                    sync_registers = true,
                    sync_registers_keymap_put = true,
                    sync_registers_keymap_reg = true,
                    sync_deletes = true,
                    sync_unnamed = true,
                },
                navigation = {
                    cycle_navigation = true,
                    enable_default_keybindings = false,
                    persist_zoom = false,
                },
                resize = {
                    enable_default_keybindings = true,
                    resize_step_x = 1,
                    resize_step_y = 1,
                },
                swap = {
                    cycle_navigation = false,
                    enable_default_keybindings = true,
                },
            })

            -- Custom navigation keymaps
            local tmux = require("tmux")
            vim.keymap.set({ "n", "t" }, "<C-h>", tmux.move_left, { desc = "[Navigation] Move to left pane" })
            vim.keymap.set({ "n", "t" }, "<C-j>", tmux.move_bottom, { desc = "[Navigation] Move to lower pane" })
            vim.keymap.set({ "n", "t" }, "<C-k>", tmux.move_top, { desc = "[Navigation] Move to upper pane" })
            vim.keymap.set({ "n", "t" }, "<C-l>", tmux.move_right, { desc = "[Navigation] Move to right pane" })
        end,
    },

    -- Opencode AI integration
    {
        "nickjvandyke/opencode.nvim",
        dependencies = {
            "folke/snacks.nvim",
        },
        event = "VeryLazy",
        config = function()
            vim.g.opencode_opts = vim.tbl_deep_extend("force", {
                provider = {
                    enabled = "snacks",
                    snacks = {
                        input = {},
                        picker = {},
                        terminal = {},
                    },
                },
            }, vim.g.opencode_opts or {})

            if not vim.g.snacks_configured then
                local ok_snacks, snacks = pcall(require, "snacks")
                if ok_snacks then
                    snacks.setup({
                        input = {},
                        picker = {},
                        terminal = {},
                    })
                    vim.g.snacks_configured = true
                end
            end
        end,
    },

    -- Snacks.nvim (dependency for opencode)
    {
        "folke/snacks.nvim",
        lazy = true,
    },
}
