-- Rust: rustaceanvim owns rust-analyzer (do not also configure it in lsp.lua)
-- and wires debuggables/testables into nvim-dap.
local function rust_capabilities()
    -- rustaceanvim builds its own capabilities from make_client_capabilities()
    -- and blink.cmp registers no global vim.lsp.config('*'), so without this
    -- rust-analyzer is the only server that misses blink's completion
    -- capabilities. Deep-merged by rustaceanvim, so its experimental flags survive.
    local ok_blink, blink = pcall(require, "blink.cmp")
    if not ok_blink then
        return nil
    end
    return blink.get_lsp_capabilities()
end

return {
    {
        "mrcjkb/rustaceanvim",
        version = "^9",
        lazy = false,
        -- No hard nvim-dap dependency: rustaceanvim autoloads it on demand, and
        -- declaring it here would drag dap into startup behind lazy = false.
        init = function()
            vim.g.rustaceanvim = {
                dap = {
                    -- Function form: resolved when a session starts, so the
                    -- lldb-dap lookup stays off the startup path.
                    adapter = function()
                        return require("custom.debugger").lldb_adapter() or false
                    end,
                    configuration = {
                        name = "Rust debug client",
                        type = "lldb",
                        request = "launch",
                        stopOnEntry = false,
                        console = "internalConsole",
                    },
                    autoload_configurations = true,
                },
                server = {
                    cmd = { vim.fn.expand("~/.cargo/bin/rust-analyzer") },
                    capabilities = rust_capabilities(),
                    on_attach = function(_, bufnr)
                        local function map(lhs, rhs, desc)
                            vim.keymap.set("n", lhs, rhs, {
                                buffer = bufnr,
                                silent = true,
                                desc = desc,
                            })
                        end

                        map("<F5>", function()
                            if require("dap").session() then
                                require("dap").continue()
                            else
                                vim.cmd.RustLsp("debug")
                            end
                        end, "[Rust] Build/debug target or continue")
                        map("<leader>rd", function()
                            vim.cmd.RustLsp("debug")
                        end, "[Rust] Build/debug target under cursor")
                        map("<leader>rD", function()
                            vim.cmd.RustLsp("debuggables")
                        end, "[Rust] Choose build/debug target")
                        map("<leader>rt", function()
                            vim.cmd.RustLsp("testables")
                        end, "[Rust] Choose test")
                    end,
                },
            }
        end,
    },
}
