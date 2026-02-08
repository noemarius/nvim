# Neovim config

Minimal Neovim configuration rooted at `init.lua`, organized under `lua/nma`.

## Structure

- `init.lua` loads `lua/nma/init.lua`.
- `lua/nma/*.lua` contains options, keymaps, autocmds, LSP, and plugin setup.
- Plugins are managed with packer (see `lua/nma/packer.lua`).

## Validation

- Full plugin sync: `nvim --headless "+PackerSync" "+qall"`
- Smoke-test a module: `nvim --headless "+luafile lua/nma/<file>.lua" "+qall"`

## Important notes

- Neovim 0.11+ is required for the built-in LSP workflow (`lua/nma/lsp.lua`).
- Format-on-save uses CLI formatters with LSP fallback; see `lua/nma/format.lua`.
- Mason auto-installs LSP servers and tools at startup; see `lua/nma/lsp.lua`.
- Keymaps live in `lua/nma/remap.lua`; plugins live in `lua/nma/packer.lua`.
- Opencode automation and cleanup live in `lua/nma/autocmds.lua`.

## Opencode workflow

This config uses `opencode.nvim` with the `snacks` provider. Opencode is launched from
inside Neovim and can be auto-opened per project when a `.opencode` file or directory
exists in the project root.

Important behavior and cleanup:

- Do not pin a single `opencode` port. Each Neovim session can run its own server.
- On exit, Neovim stops the configured opencode provider (`VimLeavePre`).
- If a crash leaves stale servers, run `:OpencodeCleanupCwd` to kill only the
  `opencode --port` processes whose CWD matches the current project.

If opencode prompts for servers, it is usually because multiple servers exist in
the same CWD. Use the cleanup command to remove the stale ones.

## References

- Agent conventions and formatting rules live in `AGENTS.md`.
- Opencode-related autocmds and the cleanup command live in `lua/nma/autocmds.lua`.
