local ok_mark, mark = pcall(require, "harpoon.mark")
local ok_ui, ui = pcall(require, "harpoon.ui")
if not (ok_mark and ok_ui) then
    return
end

vim.keymap.set("n","<leader>a", mark.add_file)
vim.keymap.set("n","<C-e>", ui.toggle_quick_menu)

vim.keymap.set("n","<leader>1", function() ui.nav_file(1) end)
vim.keymap.set("n","<leader>2", function() ui.nav_file(2) end)
vim.keymap.set("n","<leader>3", function() ui.nav_file(3) end)
vim.keymap.set("n","<leader>4", function() ui.nav_file(4) end)
vim.keymap.set("n","<leader>5", function() ui.nav_file(5) end)
vim.keymap.set("n","<leader>6", function() ui.nav_file(6) end)
vim.keymap.set("n","<leader>7", function() ui.nav_file(7) end)
vim.keymap.set("n","<leader>8", function() ui.nav_file(8) end)
vim.keymap.set("n","<leader>9", function() ui.nav_file(9) end)

-- Optional Harpoon navigation ideas
-- vim.keymap.set("n", "[h", function() ui.nav_prev() end, { desc = "Harpoon prev" })
-- vim.keymap.set("n", "]h", function() ui.nav_next() end, { desc = "Harpoon next" })
-- vim.keymap.set("n", "<leader>hh", ui.toggle_quick_menu, { desc = "Harpoon menu" })
-- vim.keymap.set("n", "<leader>hc", function() require("harpoon.mark").clear_all() end, { desc = "Clear Harpoon list" })
