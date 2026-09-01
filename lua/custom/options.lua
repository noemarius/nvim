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
set.wrap = true
set.termguicolors = true
set.scrolloff = 8
-- Two columns: diagnostics, gitsigns, marks and DAP breakpoints all draw
-- here, and a single column silently hides whichever loses the priority race.
set.signcolumn = "yes:2"
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
set.undolevels = 10000
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
set.timeoutlen = 300

-- UX
set.mouse = "a"
set.isfname:append("@-@")
set.shortmess:append("sI")

-- Better diff
set.diffopt:append({ "algorithm:histogram", "linematch:60" })

-- Session options
set.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }

-- Window title
set.title = true
set.titlestring = "../%{fnamemodify(getcwd(), ':t')} nv"

-- Project-local config
-- Opt-in for project-local config in untrusted repos.
set.exrc = vim.env.NVIM_ENABLE_EXRC == "1"
set.secure = true
