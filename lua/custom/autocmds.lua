local vim = vim
local api = vim.api
local uv = vim.uv or vim.loop

local function set_indent(bufnr, width)
    local buffer = vim.bo[bufnr]
    buffer.shiftwidth = width
    buffer.tabstop = width
    buffer.softtabstop = width
    buffer.expandtab = true
end

local indent_group = api.nvim_create_augroup("custom_indent", { clear = true })

api.nvim_create_autocmd("FileType", {
    group = indent_group,
    pattern = {
        "lua",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "json",
        "yaml",
        "html",
        "css",
        "scss",
    },
    callback = function(args)
        set_indent(args.buf, 2)
    end,
})

api.nvim_create_autocmd("FileType", {
    group = indent_group,
    pattern = {
        "python",
        "go",
        "rust",
        "java",
        "c",
        "cpp",
    },
    callback = function(args)
        set_indent(args.buf, 4)
    end,
})

local netrw_group = api.nvim_create_augroup("custom_netrw", { clear = true })

api.nvim_create_autocmd("FileType", {
    group = netrw_group,
    pattern = "netrw",
    callback = function(args)
        -- Netrw sets buffer-local C-h/j/k/l mappings; clear them for tmux navigation.
        pcall(vim.keymap.del, "n", "<C-h>", { buffer = args.buf })
        pcall(vim.keymap.del, "n", "<C-j>", { buffer = args.buf })
        pcall(vim.keymap.del, "n", "<C-k>", { buffer = args.buf })
        pcall(vim.keymap.del, "n", "<C-l>", { buffer = args.buf })
    end,
})

local yank_group = api.nvim_create_augroup("custom_yank", { clear = true })

api.nvim_create_autocmd("TextYankPost", {
    group = yank_group,
    desc = "Briefly highlight yanked text",
    callback = function()
        vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
    end,
})

-- Opencode lifecycle lives in its own module; it is ~300 lines of tmux port
-- discovery and debounced reattachment that has nothing to do with the
-- filetype/indent autocmds above.
require("custom.opencode")
