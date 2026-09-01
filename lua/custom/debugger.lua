-- Shared debug-adapter discovery.
-- Both the generic nvim-dap setup and rustaceanvim's dap block need an
-- lldb-dap binary; resolving it here keeps the path out of two plugin specs
-- and off a hardcoded Xcode.app location that breaks on CommandLineTools-only
-- machines or a relocated Xcode.

local M = {}

-- `false` means "looked and did not find", so we only pay for the lookup once.
local cached_lldb_dap = nil

function M.lldb_dap_path()
    if cached_lldb_dap ~= nil then
        return cached_lldb_dap or nil
    end

    -- PATH first: covers brew llvm and rustup-provided builds.
    if vim.fn.executable("lldb-dap") == 1 then
        cached_lldb_dap = vim.fn.exepath("lldb-dap")
        return cached_lldb_dap
    end

    -- Otherwise ask xcrun for whatever the active developer directory provides.
    if vim.fn.executable("xcrun") == 1 then
        local result = vim.system({ "xcrun", "-f", "lldb-dap" }, { text = true }):wait(5000)
        if result and result.code == 0 then
            local path = vim.trim(result.stdout or "")
            if path ~= "" and vim.fn.executable(path) == 1 then
                cached_lldb_dap = path
                return cached_lldb_dap
            end
        end
    end

    cached_lldb_dap = false
    return nil
end

-- Returns an nvim-dap executable adapter, or nil when lldb-dap is unavailable.
-- Callers resolve this lazily so startup never pays for the xcrun lookup.
function M.lldb_adapter()
    local path = M.lldb_dap_path()
    if not path then
        vim.notify("lldb-dap not found; install Xcode command line tools or `brew install llvm`", vim.log.levels.ERROR)
        return nil
    end

    return {
        type = "executable",
        command = path,
        name = "lldb",
        options = {
            initialize_timeout_sec = 20,
        },
    }
end

return M
