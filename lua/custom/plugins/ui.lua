-- UI plugins: theme, statusline, which-key, file explorer, etc.
return {
	-- Colorscheme
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("tokyonight")
			vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
			vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		end,
	},

	-- File explorer
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		cmd = "Neotree",
		keys = {
			{ "<leader>e", "<cmd>Neotree toggle<CR>", desc = "[Neo-tree] Toggle file explorer" },
		},
		opts = {
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
					hide_ignored = false,
					hide_dotfiles = false,
					hide_gitignored = true,
					hide_by_name = {},
					never_show = {},
				},
			},
		},
	},

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		opts = {
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
		},
	},

	-- Keymap discovery popup
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			delay = 300,
			icons = {
				breadcrumb = ">>",
				separator = "->",
				group = "+",
			},
		},
	},

	-- Zen mode for focused writing
	{
		"folke/zen-mode.nvim",
		cmd = "ZenMode",
		keys = {
			{ "<leader>zz", "<cmd>ZenMode<CR>", desc = "[Zen] Toggle zen mode" },
		},
		opts = {
			window = {
				width = 90,
				options = {
					signcolumn = "no",
					number = false,
					relativenumber = false,
					cursorline = false,
				},
			},
			plugins = {
				gitsigns = { enabled = false },
				tmux = { enabled = true },
			},
		},
	},

	-- LSP progress indicator
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		opts = {
			notification = {
				window = {
					winblend = 0,
				},
			},
		},
	},

	-- Highlight TODO/FIXME/HACK comments
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "VeryLazy",
		keys = {
			{ "<leader>tt", "<cmd>TodoTelescope<CR>", desc = "[Todo] Search TODOs" },
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "[Todo] Next todo",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "[Todo] Previous todo",
			},
		},
		opts = {},
	},

	-- Marks visualization
	{
		"chentoast/marks.nvim",
		event = "VeryLazy",
		opts = {
			default_mappings = true,
			builtin_marks = { ".", "<", ">", "^" },
			cyclic = true,
			force_write_shada = false,
			refresh_interval = 250,
			sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
			excluded_filetypes = {},
			excluded_buftypes = {},
			bookmark_0 = {
				sign = "⚑",
				virt_text = "hello world",
				annotate = false,
			},
			mappings = {},
		},
	},
}
