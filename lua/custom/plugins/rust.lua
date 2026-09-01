return {
    {
        "mrcjkb/rustaceanvim",
        version = "^9",
        lazy = false,
        dependencies = { "mfussenegger/nvim-dap" },
        init = function()
            vim.g.rustaceanvim = {
                dap = {
                    adapter = {
                        type = "executable",
                        command = "/Applications/Xcode.app/Contents/Developer/usr/bin/lldb-dap",
                        name = "lldb",
                        options = {
                            initialize_timeout_sec = 20,
                        },
                    },
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
                    on_attach = function(_, bufnr)
                        local dap = require("dap")
                        local function map(lhs, rhs, desc)
                            vim.keymap.set("n", lhs, rhs, {
                                buffer = bufnr,
                                silent = true,
                                desc = desc,
                            })
                        end

                        map("<F5>", function()
                            if dap.session() then
                                dap.continue()
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
