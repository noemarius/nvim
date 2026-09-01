# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Personal Neovim configuration (Lua). Requires Neovim 0.12+ (built-in LSP workflow and the pinned nvim-treesitter).

## Validation Commands

```bash
# Full plugin sync (the main "build" step)
nvim --headless "+Lazy sync" "+qa"

# Smoke-test a single module
nvim --headless "+luafile lua/custom/<file>.lua" "+qa"

# Format Lua files
stylua lua/**/*.lua

# Install Tree-sitter parsers (requires the `tree-sitter` CLI on PATH)
nvim --headless "+TSInstallDefaults" "+qa"
nvim --headless "+TSMissing" "+qa"

# Lint (if available)
luacheck lua/custom/<file>.lua
```

## Architecture

Entry point is `init.lua` → `require("custom")` → `lua/custom/init.lua`, which loads modules in order:

1. **options** — editor settings (indentation, search, display, exrc opt-in via `NVIM_ENABLE_EXRC=1`)
2. **lazy** — lazy.nvim bootstrap and plugin specs from `lua/custom/plugins/`
3. **autocmds** — filetype-based indent rules, yank highlight; requires **opencode** (`lua/custom/opencode.lua`), which owns tmux port discovery and reattach
4. **remap** — all keymaps (leader is Space); exports `apply_lsp_keymaps()` used by lsp.lua on `LspAttach`
5. **format** — format-on-save: dispatches to CLI formatters (stylua, prettier, ruff, csharpier, rustfmt) per filetype with LSP fallback
6. **lsp** — diagnostics config and LspAttach keymaps

Support modules loaded on demand rather than in the boot sequence:

- **debugger** (`lua/custom/debugger.lua`) — resolves `lldb-dap` via PATH then `xcrun`; shared by `plugins/debug.lua` and `plugins/rust.lua` so the path is never hardcoded

Plugin specs live in `lua/custom/plugins/`:

- **editor.lua** — surround, autopairs, comment, indent-blankline, refactoring
- **ui.lua** — tokyonight, neo-tree, lualine, which-key, zen-mode, todo-comments, marks
- **git.lua** — fugitive, gitsigns (with on_attach keymaps)
- **lsp.lua** — mason, mason-lspconfig, mason-tool-installer, blink.cmp, native vim.lsp.config
- **telescope.lua** — telescope + fzf extension
- **treesitter.lua** — treesitter + context
- **tools.lua** — harpoon2, trouble, undotree, tmux, opencode, snacks
- **rust.lua** — rustaceanvim; owns rust-analyzer and the Rust dap wiring
- **debug.lua** — nvim-dap + dap-ui in one spec, lazy-loaded via `keys`

## Code Style

- 4-space indentation (enforced by `.stylua.toml`)
- Double-quoted strings, trailing commas in multi-line tables
- `local` declarations for module-level requires, grouped at top of file
- Guard optional plugins with `pcall(require, "...")` before use
- Keymaps use `vim.keymap.set` with `desc` option for which-key integration
- Surface errors via `vim.notify`, never silent failures

## Key Conventions

- Modules live under `lua/custom/` matching `require("custom.<name>")` paths
- No build artifacts or compilation; validation is launching Neovim
- Plugin-specific keymaps defined in their lazy.nvim specs (keys table)
- LSP servers configured with native `vim.lsp.config`/`vim.lsp.enable` API — **except Rust**, which rustaceanvim owns entirely; do not add a `rust_analyzer` entry to `plugins/lsp.lua`
- rustaceanvim builds its own capabilities, so blink's are passed explicitly in `plugins/rust.lua`; every other server gets them from `lsp_capabilities()`
- Tree-sitter parsers need the `tree-sitter` CLI (`brew install tree-sitter`); `install()`/`update()` are async and must be `:wait()`ed in script contexts, or they are silently abandoned
- Single-key `<leader>x` maps must not share a prefix with a keymap group, or the group is gated behind `timeoutlen` (hence `<leader>D`/`<leader>X`/`<leader>A`)
- Completions via blink.cmp (Rust-based), Harpoon 2 for file navigation
- Opencode integration: auto-opens when `.opencode` file/dir exists in project root; cleanup stale servers with `:OpencodeCleanupCwd`
- The `remap.lua` module returns a table — `apply_lsp_keymaps()` is called from lsp.lua's `LspAttach` autocmd, not at load time
