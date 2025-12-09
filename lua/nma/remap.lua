vim.g.mapleader = " "                                                                               -- Set leader key to space
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)                                                       -- Open file explorer
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")                                                        -- Move selected line/block down
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")                                                        -- Move selected line/block up

vim.keymap.set("n", "J", "mzJ`z")                                                                   -- Join line below to the current line with a space
vim.keymap.set("n", "<C-d>", "<C-d>zz")                                                             -- Scroll down and center cursor
vim.keymap.set("n", "<C-u>", "<C-u>zz")                                                             -- Scroll up and center cursor
vim.keymap.set("n", "<leader>ey",
    "<cmd>lua vim.diagnostic.open_float()<CR><cmd>lua vim.diagnostic.open_float()<CR>ggVG\"+Y<CR>") -- Open diagnostics float and copy all text to clipboard

-- Optional diagnostic navigation helpers
-- vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
-- vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
-- vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Diagnostic hover" })
-- vim.keymap.set("n", "<leader>e", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- vim.keymap.set("n", "n", "nzzzv") -- Center cursor after searching next occurrence
-- vim.keymap.set("n", "N", "Nzzzv") -- Center cursor after searching previous occurrence

vim.keymap.set("n", "<leader>/", ":nohl<CR>")
-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]]) -- Paste without overwriting register

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]]) -- Yank to system clipboard
vim.keymap.set("n", "<leader>Y", [["+Y]])          -- Yank line to system clipboard

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]]) -- Delete without overwriting register


-- Optional buffer management
-- vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
-- vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Prev buffer" })
-- vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

vim.keymap.set("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Force quit Neovim" })
vim.keymap.set("n", "<leader>q", "<cmd>qa<CR>", { desc = "Quit Neovim" })

-- Quick write/source ideas
-- vim.keymap.set("n", "<leader>w", ":write<CR>", { desc = "Save file" })
-- vim.keymap.set("n", "<leader>W", ":wall<CR>", { desc = "Save all" })
-- vim.keymap.set("n", "<leader><leader>", function() vim.cmd("so") end, { desc = "Source current file" })

vim.keymap.set("n", "Q", "<nop>")                                                        -- Disable Ex mode
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)                                     -- Format code using LSP

-- Optional LSP convenience bindings
-- vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
-- vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
-- vim.keymap.set("n", "<leader>fm", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format buffer" })
-- vim.keymap.set("n", "gh", vim.lsp.buf.hover, { desc = "Hover info" })
-- vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Goto implementation" })

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")                                         -- Go to next item in quickfix list and center cursor
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")                                         -- Go to previous item in quickfix list and center cursor
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")                                     -- Go to next item in location list and center cursor
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")                                     -- Go to previous item in location list and center cursor

-- Optional window management helpers
-- vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Vertical split" })
-- vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Horizontal split" })
-- vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Balance windows" })
-- vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Left window" })
-- vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Lower window" })
-- vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Upper window" })
-- vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Right window" })

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]) -- Replace word under cursor
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })              -- Make current file executable

vim.keymap.set(
    "n",
    "<leader>ee",
    "oif err != nil {<CR>}<Esc>Oreturn nil, err<Esc>"
)                                                                                  -- Insert Go error handling snippet

vim.keymap.set("n", "<leader>vpp", "<cmd>e ~/.config/nvim/lua/nma/packer.lua<CR>") -- Open packer.lua file
vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>")       -- Run CellularAutomaton make_it_rain

-- vim.keymap.set("n", "<leader><leader>", function()
--     vim.cmd("so")
-- end) -- Source current file

vim.keymap.set('n', '<leader>cc', '<cmd>ClaudeCode<CR>', { desc = 'Toggle Claude Code' })
