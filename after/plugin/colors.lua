local function apply_colorscheme(color)
    color = color or "tokyonight"
    local ok, err = pcall(vim.cmd.colorscheme, color)
    if not ok then
        vim.notify("Colorscheme '" .. color .. "' not found: " .. err, vim.log.levels.WARN)
        return
    end
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

apply_colorscheme()
