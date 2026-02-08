-- This file can be loaded by calling `lua require("plugins")` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd.packadd("packer.nvim")

return require("packer").startup(function(use)
	-- Packer can manage itself
	use({
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
					enabled = false,
					refresh_interval = 5000,
				},
				filesystem = {
					bind_to_cwd = true,
					hijack_netrw_behavior = "disabled",
					use_libuv_file_watcher = false,
					follow_current_file = {
						enabled = false,
					},
					filtered_items = {
						visible = true,
						show_hidden_count = true,
						hide_ignored = true,
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
		end,
	})
	use("wbthomason/packer.nvim")

	use({
		"nvim-telescope/telescope.nvim",
		tag = "v0.2.1",
		requires = { { "nvim-lua/plenary.nvim" } },
	})

	use({
		"nvim-telescope/telescope-fzf-native.nvim",
		run = "make",
	})

	-- use('Mofiqul/vscode.nvim') -- theme

	use("folke/tokyonight.nvim")

	use({
		"nvim-lualine/lualine.nvim",
		requires = { "nvim-tree/nvim-web-devicons", opt = true },
		config = function()
			require("lualine").setup({
				options = {
					theme = "tokyonight",
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { { "filename", path = 1 } },
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	})

	-- use({
	--     "rose-pine/neovim",
	--     as = "rose-pine",
	--     config = function()
	--         vim.cmd("colorscheme rose-pine")
	--     end
	-- })

	use("folke/trouble.nvim")

	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	})

	use("theprimeagen/harpoon")
	use("theprimeagen/vim-be-good")
	use("theprimeagen/refactoring.nvim")

	use("mbbill/undotree")
	use("tpope/vim-fugitive")

	use({
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {
					add          = { text = "│" },
					change       = { text = "│" },
					delete       = { text = "_" },
					topdelete    = { text = "‾" },
					changedelete = { text = "~" },
				},
				linehl = true,
				numhl = true,
			})
			-- Subtle line highlights (lower opacity effect via darker bg colors)
			vim.api.nvim_set_hl(0, "GitSignsAddLn", { bg = "#1a2a1a" })
			vim.api.nvim_set_hl(0, "GitSignsChangeLn", { bg = "#1a1a2a" })
			vim.api.nvim_set_hl(0, "GitSignsDeleteLn", { bg = "#2a1a1a" })
		end,
	})

	use({
		"chentoast/marks.nvim",
		-- event = "VeryLazy",
		-- opts = {},
	})

	use({ "hrsh7th/nvim-cmp" })
	use({ "hrsh7th/cmp-nvim-lsp" })
	use({ "hrsh7th/cmp-buffer" })
	use({ "hrsh7th/cmp-path" })
	use({ "hrsh7th/cmp-cmdline" })

	use({
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
	})

	use({
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		requires = { "williamboman/mason.nvim" },
	})

	use({
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require("treesitter-context").setup({
				max_lines = 3,
				trim_scope = "outer",
			})
		end,
	})

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

	use({
		"s1n7ax/nvim-window-picker",
		tag = "v2.*",
		config = function()
			require("window-picker").setup()
		end,
	})

	use({
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	})

	-- Surround selections with quotes, brackets, etc.
	use({
		"kylechui/nvim-surround",
		tag = "*",
		config = function()
			require("nvim-surround").setup()
		end,
	})

	-- Keymap discovery popup
	use({
		"folke/which-key.nvim",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
			require("which-key").setup({
				delay = 300,
				icons = {
					breadcrumb = ">>",
					separator = "->",
					group = "+",
				},
			})
		end,
	})

	-- Indent guides
	use({
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("ibl").setup({
				indent = {
					char = "│",
				},
				scope = {
					enabled = true,
					show_start = false,
					show_end = false,
					char = "▎",
				},
			})
		end,
	})

	-- Smart commenting
	use({
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	})

	-- LSP progress indicator
	use({
		"j-hui/fidget.nvim",
		config = function()
			require("fidget").setup({
				notification = {
					window = {
						winblend = 0,
					},
				},
			})
		end,
	})

	-- Highlight TODO/FIXME/HACK comments
	use({
		"folke/todo-comments.nvim",
		requires = { "nvim-lua/plenary.nvim" },
		config = function()
			require("todo-comments").setup({})
			vim.keymap.set("n", "<leader>tt", "<cmd>TodoTelescope<CR>", { desc = "[Todo] Search TODOs" })
			vim.keymap.set("n", "]t", function()
				require("todo-comments").jump_next()
			end, { desc = "[Todo] Next todo" })
			vim.keymap.set("n", "[t", function()
				require("todo-comments").jump_prev()
			end, { desc = "[Todo] Previous todo" })
		end,
	})

	-- Auto-close HTML/JSX tags
	use({
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup({
				opts = {
					enable_close = true,
					enable_rename = true,
					enable_close_on_slash = false,
				},
			})
		end,
	})

    use({
        "nickjvandyke/opencode.nvim",
        requires = {
            {
                "folke/snacks.nvim",
            },
        },
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
                else
                    vim.notify("snacks.nvim not available for opencode", vim.log.levels.WARN)
                end
            end
        end,
    })
end)
