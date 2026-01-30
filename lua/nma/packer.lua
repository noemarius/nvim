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
		tag = "0.1.8",
		-- or                            , branch = "0.1.x",
		requires = { { "nvim-lua/plenary.nvim" } },
	})

	-- use('Mofiqul/vscode.nvim') -- theme

	use("folke/tokyonight.nvim")

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
		run = function()
			local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
			ts_update()
		end,
	})

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

	use({ "hrsh7th/nvim-cmp" })

	use({ "hrsh7th/cmp-nvim-lsp" })

	use({
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
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

	use({
		"NickvanDyke/opencode.nvim",
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
