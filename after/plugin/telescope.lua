local ok_telescope, telescope = pcall(require, "telescope")
local ok_builtin, builtin = pcall(require, "telescope.builtin")
if not (ok_telescope and ok_builtin) then
    return
end

telescope.setup({
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
})

-- Load fzf extension for faster fuzzy finding
pcall(telescope.load_extension, "fzf")

vim.keymap.set("n", "<leader>tf", builtin.find_files, { desc = "[Telescope] Find files" })
vim.keymap.set("n", "<leader>tg", builtin.git_files, { desc = "[Telescope] Git files" })
vim.keymap.set("n", "<leader>ti", function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end, { desc = "[Telescope] Grep input" })
vim.keymap.set("n", "<leader>tl", builtin.live_grep, { desc = "[Telescope] Live grep" })
vim.keymap.set("n", "<leader>tb", builtin.buffers, { desc = "[Telescope] Buffers" })
vim.keymap.set("n", "<leader>th", builtin.help_tags, { desc = "[Telescope] Help tags" })
vim.keymap.set("n", "<leader>tr", builtin.resume, { desc = "[Telescope] Resume last" })
vim.keymap.set("n", "<leader>td", builtin.diagnostics, { desc = "[Telescope] Diagnostics" })
vim.keymap.set("n", "<leader>ts", builtin.lsp_document_symbols, { desc = "[Telescope] Document symbols" })
vim.keymap.set("n", "<leader>tw", builtin.lsp_workspace_symbols, { desc = "[Telescope] Workspace symbols" })
