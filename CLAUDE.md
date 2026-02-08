# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Personal Neovim configuration (Lua). Requires Neovim 0.11+ for the built-in LSP workflow.

## Validation Commands

```bash
# Full plugin sync (the main "build" step)
nvim --headless "+PackerSync" "+qall"

# Smoke-test a single module
nvim --headless "+luafile lua/nma/<file>.lua" "+qall"

# Format Lua files
stylua lua/**/*.lua

# Lint (if available)
luacheck lua/nma/<file>.lua
```

## Architecture

Entry point is `init.lua` → `require("nma")` → `lua/nma/init.lua`, which loads modules in order:

1. **options** — editor settings (indentation, search, display)
2. **autocmds** — filetype-based indent rules, opencode lifecycle (auto-open, cleanup, exit)
3. **remap** — all keymaps (leader is Space); exports `apply_lsp_keymaps()` used by lsp.lua on `LspAttach`
4. **format** — format-on-save: dispatches to CLI formatters (stylua, prettier, black, csharpier) per filetype with LSP fallback for unknown types; Go/Rust use LSP directly
5. **packer** — plugin declarations and inline configs (packer.nvim manages everything)
6. **lsp** — Mason auto-installs servers/tools, configures each LSP via `vim.lsp.config`/`vim.lsp.enable`, sets up nvim-cmp completion

Plugin-specific keymaps and setup live in `after/plugin/` (telescope, treesitter, harpoon, fugitive, marks, undotree, colors).

## Code Style

- 4-space indentation (Lua files use 2 in practice per stylua; see existing files)
- Double-quoted strings, trailing commas in multi-line tables
- `local` declarations for module-level requires, grouped at top of file
- Guard optional plugins with `pcall(require, "...")` before use
- Keymaps use `vim.keymap.set` with `desc` option for which-key integration
- Surface errors via `vim.notify`, never silent failures

## Key Conventions

- Modules live under `lua/nma/` matching `require("nma.<name>")` paths
- No build artifacts or compilation; validation is launching Neovim
- Opencode integration: auto-opens when `.opencode` file/dir exists in project root; cleanup stale servers with `:OpencodeCleanupCwd`
- The `remap.lua` module returns a table — `apply_lsp_keymaps()` is called from lsp.lua's `LspAttach` autocmd, not at load time
