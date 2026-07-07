# Neovim Config Critical Review & Improvement Roadmap

## Executive Summary

This Neovim configuration has a solid foundation but suffered from **fragmentation**, **deprecated tooling**, and **inconsistent patterns**. The main issues were:

1. Using deprecated **Packer** instead of lazy.nvim
2. Configuration logic **scattered across 15+ files** with no clear boundaries
3. **Duplicated/conflicting settings** between modules
4. **Dead commented-out code** everywhere
5. **Inconsistent keymap definitions** (some with descriptions, some without)
6. **Outdated plugin versions** and APIs

---

## ✅ Completed Changes

### Phase 1: Foundation Cleanup ✅

| Task                     | Status  | Details                                                                          |
| ------------------------ | ------- | -------------------------------------------------------------------------------- |
| Remove dead code         | ✅ Done | Removed ~65 lines of commented-out code from remap.lua, autocmds.lua, packer.lua |
| Fix duplicate signcolumn | ✅ Done | Removed from lsp.lua (kept in options.lua)                                       |
| Remove lazyredraw        | ✅ Done | Was causing floating window issues                                               |
| Fix timeoutlen conflict  | ✅ Done | Consolidated to 300ms in options.lua only                                        |
| Add keymap descriptions  | ✅ Done | Added `desc` to 13 keymaps in harpoon.lua, fugitive.lua, undo.lua                |

### Phase 2: Plugin Manager Migration ✅

| Task                       | Status  | Details                                                          |
| -------------------------- | ------- | ---------------------------------------------------------------- |
| Create lazy.nvim bootstrap | ✅ Done | `lua/custom/lazy.lua` with proper error handling                 |
| Convert plugin specs       | ✅ Done | Created 7 modular specs in `lua/custom/plugins/`                 |
| Enable lazy loading        | ✅ Done | Added `event`, `cmd`, `keys` triggers throughout                 |
| Delete packer artifacts    | ✅ Done | Removed packer.lua, tmux.lua, packer_compiled.lua, after/plugin/ |

**New plugin structure:**

```
lua/custom/plugins/
├── init.lua          # Aggregates all specs
├── editor.lua        # surround, autopairs, comment, indent-blankline, refactoring
├── ui.lua            # tokyonight, neo-tree, lualine, which-key, zen-mode, todo-comments, marks
├── git.lua           # fugitive, gitsigns (with on_attach keymaps)
├── lsp.lua           # mason, mason-lspconfig, mason-tool-installer, blink.cmp
├── telescope.lua     # telescope + fzf extension
├── treesitter.lua    # treesitter + context
└── tools.lua         # harpoon, trouble, undotree, tmux, opencode, snacks
```

### Phase 3: Architecture Refactor ✅

| Task                                   | Status  | Details                                          |
| -------------------------------------- | ------- | ------------------------------------------------ |
| Consolidate after/plugin files         | ✅ Done | All configs moved into lazy.nvim plugin specs    |
| Remove gitsigns keymaps from remap.lua | ✅ Done | Now defined in git.lua `on_attach`               |
| Remove tmux keymaps from remap.lua     | ✅ Done | Now defined in tools.lua config                  |
| Simplify init chain                    | ✅ Done | options → lazy → autocmds → remap → format → lsp |

### Phase 4: LSP & Diagnostic Config ✅

| Task                            | Status  | Details                                    |
| ------------------------------- | ------- | ------------------------------------------ |
| Add diagnostic configuration    | ✅ Done | Custom signs (󰅚󰀪󰌶), borders, severity sort |
| Remove cmp setup from lsp.lua   | ✅ Done | Moved to plugins/lsp.lua                   |
| Remove mason setup from lsp.lua | ✅ Done | Handled by lazy.nvim plugin specs          |
| Simplify lsp.lua                | ✅ Done | Now only native vim.lsp.config/enable      |

### Phase 5: Format Improvements ✅

| Task                       | Status  | Details                                     |
| -------------------------- | ------- | ------------------------------------------- |
| Add binary file protection | ✅ Done | Skips images, PDFs, zips, executables, etc. |
| Add FormatToggle command   | ✅ Done | `:FormatToggle` enables/disables autoformat |
| Add Ruff for Python        | ✅ Done | Faster than black, with black as fallback   |

### Phase 6: Polish & QoL ✅

| Task               | Status  | Details                                             |
| ------------------ | ------- | --------------------------------------------------- |
| Add health check   | ✅ Done | `lua/custom/health.lua` - run `:checkhealth custom` |
| Add undolevels     | ✅ Done | Set to 10000 for deep undo history                  |
| Add diffopt        | ✅ Done | algorithm:histogram, linematch:60                   |
| Add sessionoptions | ✅ Done | buffers, curdir, tabpages, winsize                  |
| Add shortmess      | ✅ Done | Reduce command line noise                           |
| Update README      | ✅ Done | New structure documentation                         |

---

## Final File Structure

```
~/.config/nvim/
├── init.lua                    # Entry point
├── README.md                   # Updated documentation
├── AGENTS.md                   # Agent conventions
├── CLAUDE.md                   # Claude-specific notes
└── lua/custom/
    ├── init.lua                # Main loader
    ├── options.lua             # Vim options
    ├── lazy.lua                # lazy.nvim bootstrap
    ├── remap.lua               # Core keymaps (non-plugin)
    ├── autocmds.lua            # Autocommands
    ├── format.lua              # Format-on-save with binary protection
    ├── lsp.lua                 # Native LSP config (0.11+)
    ├── health.lua              # Health check module
    └── plugins/
        ├── init.lua            # Plugin loader
        ├── editor.lua          # Core editing plugins
        ├── ui.lua              # UI enhancements
        ├── git.lua             # Git integration
        ├── lsp.lua             # LSP & completion
        ├── telescope.lua       # Fuzzy finder
        ├── treesitter.lua      # Syntax highlighting
        └── tools.lua           # Utilities
```

---

## Deleted Files

- `lua/custom/packer.lua` - Replaced by lazy.nvim
- `lua/custom/tmux.lua` - Moved to plugins/tools.lua
- `plugin/packer_compiled.lua` - Packer artifact
- `after/plugin/*.lua` (10 files) - Consolidated into plugin specs:
  - colors.lua → plugins/ui.lua
  - telescope.lua → plugins/telescope.lua
  - treesitter.lua → plugins/treesitter.lua
  - harpoon.lua → plugins/tools.lua
  - trouble.lua → plugins/tools.lua
  - fugitive.lua → plugins/git.lua
  - marks.lua → plugins/ui.lua
  - refactoring.lua → plugins/editor.lua
  - undo.lua → plugins/tools.lua
  - zen.lua → plugins/ui.lua

---

## Validation Commands

```bash
# Sync plugins (first run)
nvim --headless "+Lazy sync" "+qa"

# Health check
nvim -c "checkhealth custom"

# Check startup time
nvim --startuptime /tmp/startup.log +qa && tail -1 /tmp/startup.log

# Smoke-test config
nvim --headless -c "lua require('custom')" -c "qa"
```

---

## Key Improvements Summary

| Metric                 | Before              | After                   |
| ---------------------- | ------------------- | ----------------------- |
| Plugin manager         | Packer (deprecated) | lazy.nvim               |
| Config files           | 15+ scattered       | 8 organized modules     |
| Dead code lines        | ~100+               | 0                       |
| Keymaps without desc   | 13                  | 0                       |
| Plugin lazy-loading    | None                | Event/cmd/keys triggers |
| Health check           | None                | `:checkhealth custom`   |
| Binary file protection | None                | Full protection         |
| Diagnostic UI          | Default             | Custom signs + borders  |
| Completion engine      | nvim-cmp            | blink.cmp (Rust)        |
| Harpoon                | v1 API              | v2 API                  |

---

## Phase 7: Quick Wins ✅

| Task                               | Status  | Details                                                              |
| ---------------------------------- | ------- | -------------------------------------------------------------------- |
| Delete leftover after/plugin files | ✅ Done | Removed `fugitive.lua`, `harpoon.lua`, `undo.lua`                    |
| Enable exrc support                | ✅ Done | Added `vim.opt.exrc = true` + `vim.opt.secure = true` to options.lua |
| Remove cellular-automaton          | ✅ Done | Deleted spec from plugins/ui.lua                                     |

---

## Phase 8: Harpoon 2 Migration ✅

| Task                     | Status  | Details                                                                 |
| ------------------------ | ------- | ----------------------------------------------------------------------- |
| Update plugin spec       | ✅ Done | Added `branch = "harpoon2"`, plenary dependency                         |
| Rewrite keymaps          | ✅ Done | New API: `harpoon:list():add()`, `:select(n)`, `ui:toggle_quick_menu()` |
| Resolve `<C-e>` conflict | ✅ Done | Changed to `<leader>e` for Harpoon menu                                 |
| Add config function      | ✅ Done | Initialized harpoon instance with `harpoon:setup({})`                   |
| Add prev/next navigation | ✅ Done | `<C-S-P>` / `<C-S-N>` for cycling through marks                         |

---

## Phase 9: blink.cmp Migration ✅

| Task                    | Status  | Details                                         |
| ----------------------- | ------- | ----------------------------------------------- |
| Replace nvim-cmp        | ✅ Done | Removed nvim-cmp + 4 cmp-\* plugins             |
| Add blink.cmp           | ✅ Done | Added `saghen/blink.cmp` with version lock      |
| Configure sources       | ✅ Done | LSP, buffer, path, snippets, cmdline            |
| Translate keymaps       | ✅ Done | Tab/S-Tab, C-Space, CR confirm, C-e cancel      |
| Update LSP capabilities | ✅ Done | Using `blink.get_lsp_capabilities()` in lsp.lua |
| Signature help          | ✅ Done | Enabled built-in signature help                 |

---

## Validation Commands

```bash
# Sync plugins
nvim --headless "+Lazy sync" "+qa"

# Health check
nvim -c "checkhealth custom"

# Check startup time
nvim --startuptime /tmp/startup.log +qa && tail -1 /tmp/startup.log

# Smoke-test config
nvim --headless -c "lua require('custom')" -c "qa"
```

---

## Phase 10: Config Review Fixes ✅

| Task                              | Status  | Details                                                                                            |
| --------------------------------- | ------- | ------------------------------------------------------------------------------------------------- |
| Enforce format style             | ✅ Done | Added `.stylua.toml` (4-space, spaces); normalized all Lua files (previously mixed tabs/spaces)    |
| Fix format.lua LSP API           | ✅ Done | `client.supports_method` → `client:supports_method` (dot form deprecated, removed in Nvim 0.13)   |
| Fix format.lua timeout branch    | ✅ Done | Detect timeout via `result.code == 124`; removed dead `if not result` block                        |
| Migrate opencode provider→server | ✅ Done | `autocmds.lua` now uses `opencode.server` + nested `server.port` (plugin removed `provider`)       |
| Reduce keymap friction           | ✅ Done | Harpoon prev/next → `[a`/`]a`; splits → `<leader>wv`/`<leader>ws` (removes `<leader>s` timeout)    |
| Sync documentation               | ✅ Done | README keymaps/exrc/version, AGENTS.md style contradiction, CLAUDE.md version, health.lua 0.12 gate |

> Note: exrc is **opt-in** via `NVIM_ENABLE_EXRC=1` (supersedes the Phase 7 "enabled" note).

---

## Summary

| Phase | Focus                                                    | Status      |
| ----- | -------------------------------------------------------- | ----------- |
| 1-6   | Foundation, lazy.nvim, architecture, LSP, format, polish | ✅ Complete |
| 7     | Quick wins (exrc, cleanup)                               | ✅ Complete |
| 8     | Harpoon 2 migration                                      | ✅ Complete |
| 9     | blink.cmp migration                                      | ✅ Complete |
| 10    | Config review fixes (style, format, opencode, docs)      | ✅ Complete |
