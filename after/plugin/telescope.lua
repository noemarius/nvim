local telescope = require('telescope')
local builtin = require('telescope.builtin')

telescope.setup {
    pickers = {
        find_files = {
            hidden = true
        },
    },
    defaults = {
        file_ignore_patterns = {
            "node_modules", ".git",".keep"

        },
    }
}
-- telescope.setup {
--     defaults = {
--         vimgrep_arguments = {
--             'rg',
--             '--color=never',
--             '--no-heading',
--             '--with-filename',
--             '--line-number',
--             '--column',
--             '--smart-case',
--             '--hidden',
--         },
--     } };


vim.keymap.set('n', '<leader>tf', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>tg', builtin.git_files, { desc = 'Telescope find git files' })
vim.keymap.set('n', '<leader>ti', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end
)

-- Optional picker bindings for later use
-- vim.keymap.set('n', '<leader>tl', builtin.live_grep, { desc = 'Telescope live grep' })
-- vim.keymap.set('n', '<leader>tb', builtin.buffers, { desc = 'Telescope buffers' })
-- vim.keymap.set('n', '<leader>th', builtin.help_tags, { desc = 'Telescope help' })
-- vim.keymap.set('n', '<leader>tr', builtin.resume, { desc = 'Telescope resume last' })
-- vim.keymap.set('n', '<leader>td', builtin.diagnostics, { desc = 'Telescope diagnostics' })
