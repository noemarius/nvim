-- Debugging: nvim-dap plus its UI.
-- Both live in one spec so there is a single lazy trigger point; dap-ui's
-- listeners must be registered in the same pass that loads dap, otherwise
-- starting a session would not open the UI.
local function setup_dap()
    local dap = require("dap")
    local dapui = require("dapui")
    local debugger = require("custom.debugger")

    -- Function form: nvim-dap evaluates this when a session starts, so the
    -- xcrun lookup never runs at startup.
    dap.adapters.lldb = function(callback)
        local adapter = debugger.lldb_adapter()
        if adapter then
            callback(adapter)
        end
    end

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
end

return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
        },
        cmd = { "DapContinue", "DapToggleBreakpoint", "DapTerminate" },
        keys = {
            {
                "<F5>",
                function()
                    require("dap").continue()
                end,
                desc = "[DAP] Continue",
            },
            {
                "<F9>",
                function()
                    require("dap").toggle_breakpoint()
                end,
                desc = "[DAP] Toggle breakpoint",
            },
            {
                "<F10>",
                function()
                    require("dap").step_over()
                end,
                desc = "[DAP] Step over",
            },
            {
                "<F11>",
                function()
                    require("dap").step_into()
                end,
                desc = "[DAP] Step into",
            },
            {
                "<F12>",
                function()
                    require("dap").step_out()
                end,
                desc = "[DAP] Step out",
            },
            {
                "<leader>dr",
                function()
                    require("dap").repl.open()
                end,
                desc = "[DAP] Open REPL",
            },
            {
                "<leader>dl",
                function()
                    require("dap").run_last()
                end,
                desc = "[DAP] Run last",
            },
            {
                "<leader>dt",
                function()
                    require("dap").terminate()
                end,
                desc = "[DAP] Terminate",
            },
            {
                "<leader>db",
                function()
                    require("dap").clear_breakpoints()
                end,
                desc = "[DAP] Clear all breakpoints",
            },
            {
                "<leader>dh",
                function()
                    require("dap.ui.widgets").hover()
                end,
                mode = { "n", "v" },
                desc = "[DAP] Hover value",
            },
            {
                "<leader>du",
                function()
                    require("dapui").toggle()
                end,
                desc = "[DAP] Toggle UI",
            },
            {
                "<leader>de",
                function()
                    require("dapui").eval()
                end,
                mode = { "n", "v" },
                desc = "[DAP] Evaluate expression",
            },
            {
                "<leader>ds",
                function()
                    require("dapui").float_element("scopes", { enter = true })
                end,
                desc = "[DAP] Show scopes",
            },
        },
        config = setup_dap,
    },

    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        lazy = true,
    },

    {
        "nvim-neotest/nvim-nio",
        lazy = true,
    },
}
