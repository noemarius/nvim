-- This file can be loaded by calling `lua require("plugins")` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd.packadd("packer.nvim")

return require("packer").startup(function(use)
    -- Packer can manage itself
    use {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
            -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
        },
        config = function()
            require("neo-tree").setup({
                git_status = {
                    enabled = true,
                    refresh_interval = 1000,
                },
                filesystem = {
                    use_libuv_file_watcher = true,
                    follow_current_file = {
                        enabled = false,
                    },
                    filtered_items = {
                        visible = true,
                        show_hidden_count = true,
                        hide_dotfiles = false,
                        hide_gitignored = true,
                        hide_by_name = {
                            -- add extension names you want to explicitly exclude
                            -- '.git',
                            -- '.DS_Store',
                            -- 'thumbs.db',
                        },
                        never_show = {},
                    },
                },
            })
            vim.api.nvim_create_autocmd("BufEnter", {
                callback = function()
                    pcall(function()
                        require("neo-tree.sources.filesystem").refresh()
                    end)
                end,
            })

            vim.api.nvim_create_autocmd("BufWritePost", {
                callback = function()
                    pcall(function()
                        require("neo-tree.sources.filesystem").refresh()
                    end)
                end,
            })

            vim.api.nvim_create_autocmd("TermClose", {
                pattern = "*git*",
                callback = function()
                    pcall(function()
                        require("neo-tree.sources.git_status").refresh()
                    end)
                end,
            })

            vim.api.nvim_create_autocmd("User", {
                pattern = "GitCommit",
                callback = function()
                    pcall(function()
                        require("neo-tree.sources.filesystem").refresh()
                    end)
                    pcall(function()
                        require("neo-tree.sources.git_status").refresh()
                    end)
                end,
            })

            -- Auto close Neo-tree when opening a file
            vim.api.nvim_create_autocmd("BufEnter", {
                callback = function()
                    local buf = vim.api.nvim_get_current_buf()
                    local ft = vim.api.nvim_buf_get_option(buf, "filetype")
                    if ft ~= "neo-tree" then
                        pcall(vim.cmd, "Neotree close")
                    end
                end,
            })
            -- vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>", {})
        end,
    }
    use "wbthomason/packer.nvim"

    use {
        "nvim-telescope/telescope.nvim", tag = "0.1.8",
        -- or                            , branch = "0.1.x",
        requires = { { "nvim-lua/plenary.nvim" } }
    }

    -- use('Mofiqul/vscode.nvim') -- theme

    use("folke/tokyonight.nvim")
    --
    -- use({
    --     "rose-pine/neovim",
    --     as = "rose-pine",
    --     config = function()
    --         vim.cmd("colorscheme rose-pine")
    --     end
    -- })
    --
    use("folke/trouble.nvim")

    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end, }
    use("nvim-treesitter/playground")

    use("theprimeagen/harpoon")
    use("theprimeagen/vim-be-good")
    use("theprimeagen/refactoring.nvim")

    use("mbbill/undotree")
    use("tpope/vim-fugitive")

    use({
        "chentoast/marks.nvim",
        -- event = "VeryLazy",
        -- opts = {},
    })

    use({ 'hrsh7th/nvim-cmp' })
    use({ 'hrsh7th/cmp-nvim-lsp' })

    use({ 'VonHeikemen/lsp-zero.nvim', branch = 'v4.x' })
    use({
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'neovim/nvim-lspconfig',
    })
    --use("nvim-treesitter/nvim-treesitter-context");

    use("nvzone/volt")
    use({
        "nvzone/typr",
        dependencies = "nvzone/volt",
        opts = {},
        cmd = { "typr", "typrstats" },
    })


    use("folke/zen-mode.nvim")

    use("eandrju/cellular-automaton.nvim")
    use("laytan/cloak.nvim")


    use {
        's1n7ax/nvim-window-picker',
        tag = 'v2.*',
        config = function()
            require 'window-picker'.setup()
        end,
    }

    use {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup {}
        end
    }

    use {
        'greggh/claude-code.nvim',
        requires = {
            'nvim-lua/plenary.nvim', -- required for git operations
        },
        config = function()
            local ok, claude = pcall(require, 'claude-code')
            if ok then
                claude.setup()
            end
        end
    }

    use("github/copilot.vim")
    use({
        "jackmort/chatgpt.nvim",
        config = function()
            local ok, chatgpt = pcall(require, "chatgpt")
            if ok then
                chatgpt.setup()
            end
        end,
        requires = {
            "muniftanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "folke/trouble.nvim",
            "nvim-telescope/telescope.nvim"
        }
    })

    -- use {
    --  "VonHeikemen/lsp-zero.nvim",
    --  branch = "v1.x",
    --  requires = {
    --   -- LSP Support
    --   {"neovim/nvim-lspconfig"},
    --   {"williamboman/mason.nvim"},
    --   {"williamboman/mason-lspconfig.nvim"},
    --
    --   -- Autocompletion
    --   {"hrsh7th/nvim-cmp"},
    --   {"hrsh7th/cmp-buffer"},
    --   {"hrsh7th/cmp-path"},
    --   {"saadparwaiz1/cmp_luasnip"},
    --   {"hrsh7th/cmp-nvim-lsp"},
    --   {"hrsh7th/cmp-nvim-lua"},
    --
    --   -- Snippets
    --   {"L3MON4D3/LuaSnip"},
    --   {"rafamadriz/friendly-snippets"},
    --  }
    -- }
end)
