local set = vim.opt

-- Line numbers
set.number = true
set.relativenumber = true

-- Indentation
set.tabstop = 4
set.softtabstop = 4
set.shiftwidth = 4
set.expandtab = true
set.smartindent = true

-- Display
set.wrap = false
set.termguicolors = true
set.scrolloff = 8
set.signcolumn = "yes"
set.colorcolumn = "80"
set.cursorline = true
set.showmode = false
set.pumheight = 10
set.list = true
set.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
set.fillchars = { eob = " " }

-- File handling
set.swapfile = false
set.backup = false
set.writebackup = false
set.undodir = os.getenv("HOME") .. "/.vim/undodir"
set.undofile = true
set.autoread = true
set.confirm = true

-- Search
set.hlsearch = true
set.incsearch = true
set.ignorecase = true
set.smartcase = true
set.grepprg = "rg --vimgrep"
set.grepformat = "%f:%l:%c:%m"

-- Splits
set.splitbelow = true
set.splitright = true

-- Performance & responsiveness
set.updatetime = 50
set.timeoutlen = 500
set.lazyredraw = true

-- UX
set.mouse = "a"
set.clipboard = "unnamedplus"
set.isfname:append("@-@")

-- Window title
set.title = true
set.titlestring = "../%{fnamemodify(getcwd(), ':t')} nv"
