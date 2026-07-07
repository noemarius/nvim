# Neovim config

Minimal Neovim configuration rooted at `init.lua`, organized under `lua/custom`.

## Structure

```
init.lua                    # Entry point, loads lua/custom/init.lua
lua/custom/
├── init.lua                # Main loader
├── options.lua             # Vim options (exrc enabled)
├── lazy.lua                # lazy.nvim bootstrap
├── remap.lua               # Core keymaps
├── autocmds.lua            # Autocommands
├── format.lua              # Format-on-save
├── lsp.lua                 # Native LSP config (0.12+)
├── health.lua              # Health check (:checkhealth custom)
└── plugins/                # Plugin specs (lazy.nvim)
    ├── init.lua            # Plugin loader
    ├── editor.lua          # Editing: surround, autopairs, comment
    ├── ui.lua              # UI: tokyonight, neo-tree, lualine, which-key, zen-mode
    ├── git.lua             # Git: fugitive, gitsigns
    ├── lsp.lua             # LSP: mason, blink.cmp
    ├── telescope.lua       # Fuzzy finder
    ├── treesitter.lua      # Syntax highlighting
    └── tools.lua           # Tools: harpoon2, trouble, undotree, tmux
```

## Validation

```bash
# Sync plugins
nvim --headless "+Lazy sync" "+qa"

# Health check
nvim -c "checkhealth custom"

# Smoke-test a module
nvim --headless "+luafile lua/custom/<file>.lua" "+qa"

# Check startup time
nvim --startuptime /tmp/startup.log +qa && tail -1 /tmp/startup.log
```

## Key features

- **Neovim 0.12+** required (native LSP workflow and the pinned nvim-treesitter)
- **lazy.nvim** for plugin management with lazy-loading
- **blink.cmp** for completions (Rust-based, replaces nvim-cmp)
- **Harpoon 2** for quick file navigation
- **exrc** opt-in for project-local config — set `NVIM_ENABLE_EXRC=1` to enable (`.nvim.lua`, `.nvimrc`)
- Format-on-save with CLI formatters and LSP fallback (`:FormatToggle` to disable)
- Mason auto-installs LSP servers and tools

## Keymaps

| Key            | Action                            |
| -------------- | --------------------------------- |
| `<leader>pv`   | Open netrw file explorer          |
| `<leader>e`    | Toggle neo-tree                   |
| `<leader>a`    | Add file to Harpoon               |
| `<leader>al`   | Toggle Harpoon menu               |
| `<leader>1`..`9` | Jump to Harpoon file            |
| `[a` / `]a`    | Previous / next Harpoon file      |
| `<C-h/j/k/l>`  | Navigate splits / tmux panes      |
| `<leader>tf`   | Find files (Telescope)            |
| `<leader>tl`   | Live grep (Telescope)             |
| `<leader>tb`   | Browse buffers (Telescope)        |
| `<leader>gs`   | Git status (Fugitive)             |
| `<leader>u`    | Toggle undotree                   |
| `<leader>zz`   | Toggle zen mode                   |
| `<leader>wv` / `<leader>ws` | Vertical / horizontal split |

## References

- Agent conventions: `AGENTS.md`
- Claude-specific notes: `CLAUDE.md`
- Migration history: `ROADMAP.md`
