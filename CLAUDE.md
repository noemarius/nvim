# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Personal Neovim configuration (Lua). Requires Neovim 0.11+ for the built-in LSP workflow.

## Validation Commands

```bash
# Full plugin sync (the main "build" step)
nvim --headless "+Lazy sync" "+qa"

# Smoke-test a single module
nvim --headless "+luafile lua/custom/<file>.lua" "+qa"

# Format Lua files
stylua lua/**/*.lua

# Lint (if available)
luacheck lua/custom/<file>.lua
```

## Architecture

Entry point is `init.lua` → `require("custom")` → `lua/custom/init.lua`, which loads modules in order:

1. **options** — editor settings (indentation, search, display, exrc enabled)
2. **lazy** — lazy.nvim bootstrap and plugin specs from `lua/custom/plugins/`
3. **autocmds** — filetype-based indent rules, opencode lifecycle
4. **remap** — all keymaps (leader is Space); exports `apply_lsp_keymaps()` used by lsp.lua on `LspAttach`
5. **format** — format-on-save: dispatches to CLI formatters (stylua, prettier, ruff, csharpier) per filetype with LSP fallback
6. **lsp** — diagnostics config and LspAttach keymaps

Plugin specs live in `lua/custom/plugins/`:

- **editor.lua** — surround, autopairs, comment, indent-blankline, refactoring
- **ui.lua** — tokyonight, neo-tree, lualine, which-key, zen-mode, todo-comments, marks
- **git.lua** — fugitive, gitsigns (with on_attach keymaps)
- **lsp.lua** — mason, mason-lspconfig, mason-tool-installer, blink.cmp, native vim.lsp.config
- **telescope.lua** — telescope + fzf extension
- **treesitter.lua** — treesitter + context
- **tools.lua** — harpoon2, trouble, undotree, tmux, opencode, snacks

## Code Style

- 4-space indentation
- Double-quoted strings, trailing commas in multi-line tables
- `local` declarations for module-level requires, grouped at top of file
- Guard optional plugins with `pcall(require, "...")` before use
- Keymaps use `vim.keymap.set` with `desc` option for which-key integration
- Surface errors via `vim.notify`, never silent failures

## Key Conventions

- Modules live under `lua/custom/` matching `require("custom.<name>")` paths
- No build artifacts or compilation; validation is launching Neovim
- Plugin-specific keymaps defined in their lazy.nvim specs (keys table)
- LSP servers configured with native `vim.lsp.config`/`vim.lsp.enable` API
- Completions via blink.cmp (Rust-based), Harpoon 2 for file navigation
- Opencode integration: auto-opens when `.opencode` file/dir exists in project root; cleanup stale servers with `:OpencodeCleanupCwd`
- The `remap.lua` module returns a table — `apply_lsp_keymaps()` is called from lsp.lua's `LspAttach` autocmd, not at load time
