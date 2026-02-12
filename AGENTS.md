# Agent Guide

## MANDATORY: Use td for Task Management

Run td usage --new-session at conversation start (or after /clear). This tells you what to work on next.

Sessions are automatic (based on terminal/agent context). Optional:
- td session "name" to label the current session
- td session --new to force a new session in the same context

Use td usage -q after first read.

1. Repo is a Neovim Lua config rooted at init.lua with lazy.nvim-managed plugins.
2. Keep modules under lua/custom mirroring require paths (e.g., require("custom.options")).
3. Build step is just launching Neovim; no compilation artifacts should be generated.
4. Run full validation with `nvim --headless "+Lazy sync" "+qa"` after touching plugins.
5. Smoke-test a single module via `nvim --headless "+luafile lua/custom/<file>.lua" "+qa"`.
6. Use `stylua lua/**/*.lua` for formatting; default config (indent=4 spaces) matches existing style.
7. Run `luacheck` if available for linting; target files you changed to keep feedback focused.
8. Prefer double-quoted strings and table constructors with trailing commas for multi-line blocks.
9. Use 4 spaces, never tabs; align chained tables and callbacks vertically.
10. Declare locals for module-level references (e.g., `local blink = require("blink.cmp")`).
11. Keep all require statements grouped at the top of each file before side effects.
12. Module naming: snake_case files inside lua/custom, PascalCase only for exported tables when needed.
13. Keymaps should be defined with `vim.keymap.set` plus descriptive comments/opts tables.
14. Favor anonymous functions only when short; otherwise extract to named locals.
15. Handle optional dependencies with `pcall(require, "...")` and guard before invoking.
16. Surface recoverable errors through `vim.notify` or log messages instead of silent failures.
17. Keep color scheme or option tweaks idempotent (safe to re-source).
18. No Cursor or Copilot instruction files exist; follow this guide and upstream plugin docs.
19. Avoid adding inline prints; rely on Neovim's :messages for debugging and remove helpers afterward.
20. Document non-obvious behaviors inline with Lua comments starting with double hyphen.
