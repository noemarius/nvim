return {
    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require("dap")

            dap.adapters.lldb = {
                type = "executable",
                command = "/Applications/Xcode.app/Contents/Developer/usr/bin/lldb-dap",
                name = "lldb",
                options = {
                    initialize_timeout_sec = 20,
                },
            }

            local signs = {
                DapBreakpoint = {
                    text = "●",
                    texthl = "DapBreakpointSign",
                    numhl = "DapBreakpointSign",
                },
                DapBreakpointCondition = {
                    text = "⊜",
                    texthl = "DapBreakpointConditionSign",
                    numhl = "DapBreakpointConditionSign",
                },
                DapBreakpointRejected = {
                    text = "⊘",
                    texthl = "DapBreakpointRejectedSign",
                    numhl = "DapBreakpointRejectedSign",
                },
                DapLogPoint = {
                    text = "◆",
                    texthl = "DapLogPointSign",
                    numhl = "DapLogPointSign",
                },
                DapStopped = {
                    text = "▶",
                    texthl = "DapStoppedSign",
                    numhl = "DapStoppedSign",
                    linehl = "DapStoppedLine",
                },
            }

            for name, sign in pairs(signs) do
                vim.fn.sign_define(name, sign)
            end

            vim.keymap.set("n", "<F5>", dap.continue, { desc = "[DAP] Continue" })
            vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "[DAP] Toggle breakpoint" })
            vim.keymap.set("n", "<F10>", dap.step_over, { desc = "[DAP] Step over" })
            vim.keymap.set("n", "<F11>", dap.step_into, { desc = "[DAP] Step into" })
            vim.keymap.set("n", "<F12>", dap.step_out, { desc = "[DAP] Step out" })
            vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "[DAP] Open REPL" })
            vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "[DAP] Run last" })
            vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "[DAP] Terminate" })
            vim.keymap.set("n", "<leader>db", dap.clear_breakpoints, { desc = "[DAP] Clear all breakpoints" })
            vim.keymap.set({ "n", "v" }, "<leader>dh", function()
                require("dap.ui.widgets").hover()
            end, { desc = "[DAP] Hover value" })
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            dapui.setup()

            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end

            vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "[DAP] Toggle UI" })
            vim.keymap.set({ "n", "v" }, "<leader>de", dapui.eval, { desc = "[DAP] Evaluate expression" })
            vim.keymap.set("n", "<leader>ds", function()
                dapui.float_element("scopes", { enter = true })
            end, { desc = "[DAP] Show scopes" })
        end,
    },
}
