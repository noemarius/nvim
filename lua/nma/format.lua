local M = {}

local format_group = vim.api.nvim_create_augroup("NmaFormat", {})
local stylua_missing_warned = false

local function apply_stylua(event)
	if vim.fn.executable("stylua") == 0 then
		if not stylua_missing_warned then
			vim.notify("stylua executable not found; skipping format on save", vim.log.levels.WARN)
			stylua_missing_warned = true
		end
		return
	end

	local bufnr = event.buf
	local filepath = vim.api.nvim_buf_get_name(bufnr)
	if filepath == "" then
		return
	end

	local source = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
	local output = vim.fn.system({
		"stylua",
		"--search-parent-directories",
		"--stdin-filepath",
		filepath,
		"-",
	}, source)

	if vim.v.shell_error ~= 0 then
		vim.notify("stylua failed: " .. output, vim.log.levels.ERROR)
		return
	end

	local formatted = vim.split(output:gsub("\r\n", "\n"), "\n", { plain = true })
	if formatted[#formatted] == "" then
		table.remove(formatted)
	end

	local current = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	if #formatted == #current then
		local identical = true
		for idx = 1, #formatted do
			if formatted[idx] ~= current[idx] then
				identical = false
				break
			end
		end
		if identical then
			return
		end
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)
end

vim.api.nvim_create_autocmd("BufWritePre", {
	group = format_group,
	pattern = "*.lua",
	callback = apply_stylua,
})

return M
