-- LSP, completion, and related tooling
-- Native vim.lsp.config requires the function form of root_dir to call the
-- on_dir callback (returning a value is ignored, and the server never starts).
local function root_dir_with(markers)
    return function(bufnr, on_dir)
        local root = vim.fs.root(bufnr, markers)
        if root then
            on_dir(root)
            return
        end
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name == "" then
            return
        end
        -- Fall back to the file's directory so standalone files still get LSP.
        on_dir(vim.fs.dirname(name))
    end
end

local function root_dir_with_patterns(patterns, markers)
    local marker_root = root_dir_with(markers)
    return function(bufnr, on_dir)
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name ~= "" then
            local start_dir = vim.fs.dirname(name)
            local match = vim.fs.find(function(fname)
                for _, pattern in ipairs(patterns) do
                    if fname:match(pattern) then
                        return true
                    end
                end
                return false
            end, { path = start_dir, upward = true, type = "file" })[1]
            if match then
                on_dir(vim.fs.dirname(match))
                return
            end
        end
        marker_root(bufnr, on_dir)
    end
end

local function lsp_capabilities()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok_blink, blink = pcall(require, "blink.cmp")
    if ok_blink then
        return blink.get_lsp_capabilities(capabilities)
    end
    return capabilities
end

local mason_ensure_installed = {
    "gopls",
    "csharp-language-server",
    "lua-language-server",
    "eslint-lsp",
    "tailwindcss-language-server",
    "dockerfile-language-server",
    "bash-language-server",
    "typescript-language-server",
    "pyright",
    "json-lsp",
    "bicep-lsp",
    "prettier",
    "black",
    "ruff",
    "stylua",
}

local servers = {
    lua_ls = {
        bin = "lua-language-server",
        filetypes = { "lua" },
        root_markers = {
            ".luarc.json",
            ".luarc.jsonc",
            ".luacheckrc",
            ".stylua.toml",
            "stylua.toml",
            "selene.toml",
            "selene.yml",
            ".git",
        },
        settings = {
            Lua = {
                completion = { callSnippet = "Replace" },
                diagnostics = { globals = { "vim" } },
                workspace = {
                    checkThirdParty = false,
                    library = vim.api.nvim_get_runtime_file("", true),
                },
            },
        },
    },
    eslint = {
        bin = "vscode-eslint-language-server",
        args = { "--stdio" },
        filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
            "vue",
            "svelte",
            "astro",
        },
        root_markers = {
            ".eslintrc",
            ".eslintrc.js",
            ".eslintrc.cjs",
            ".eslintrc.yaml",
            ".eslintrc.yml",
            ".eslintrc.json",
            "eslint.config.js",
            "eslint.config.mjs",
            "eslint.config.cjs",
        },
    },
    tailwindcss = {
        bin = "tailwindcss-language-server",
        args = { "--stdio" },
        filetypes = {
            "html",
            "css",
            "scss",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "vue",
            "svelte",
        },
        root_markers = {
            "tailwind.config.js",
            "tailwind.config.cjs",
            "tailwind.config.mjs",
            "tailwind.config.ts",
        },
    },
    dockerls = {
        bin = "docker-langserver",
        args = { "--stdio" },
        filetypes = { "dockerfile" },
        root_markers = { "Dockerfile", ".git" },
    },
    bashls = {
        bin = "bash-language-server",
        args = { "start" },
        filetypes = { "sh", "bash", "zsh" },
        root_markers = { ".git" },
    },
    ts_ls = {
        bin = "typescript-language-server",
        args = { "--stdio" },
        filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
        },
        root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
    },
    pyright = {
        bin = "pyright-langserver",
        args = { "--stdio" },
        filetypes = { "python" },
        root_markers = {
            "pyproject.toml",
            "setup.py",
            "setup.cfg",
            "requirements.txt",
            "Pipfile",
            "pyrightconfig.json",
            ".git",
        },
    },
    jsonls = {
        bin = "vscode-json-language-server",
        args = { "--stdio" },
        filetypes = { "json", "jsonc" },
        root_markers = { ".git" },
    },
    bicep = {
        bin = "bicep-lsp",
        filetypes = { "bicep" },
        root_markers = { ".git" },
    },
    gopls = {
        bin = "gopls",
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_markers = { "go.work", "go.mod", ".git" },
    },
    csharp_ls = {
        bin = "csharp-ls",
        filetypes = { "cs" },
        root_dir = root_dir_with_patterns({ "%.sln$", "%.csproj$" }, { "global.json", ".git" }),
    },
}

local function setup_lsp()
    local capabilities = lsp_capabilities()

    for name, server in pairs(servers) do
        local opts = {
            cmd = vim.list_extend({ server.bin }, server.args or {}),
            filetypes = server.filetypes,
            root_dir = server.root_dir or root_dir_with(server.root_markers),
            settings = server.settings,
            capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {}),
        }

        vim.lsp.config(name, opts)
        vim.lsp.enable(name)
    end
end

local function setup_mason()
    local mason = require("mason")
    mason.setup()
end

local function setup_mason_and_lsp()
    setup_mason()
    setup_lsp()
end

return {
    -- Mason package manager
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        lazy = false,
        priority = 100,
        config = setup_mason_and_lsp,
    },

    -- Mason tool installer for tools and LSP binaries
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = mason_ensure_installed,
            auto_update = false,
            run_on_start = true,
        },
    },

    -- Blink.cmp - fast Rust-based completion
    {
        "saghen/blink.cmp",
        version = "1.*",
        event = { "InsertEnter", "CmdlineEnter" },
        opts = {
            keymap = {
                preset = "default",
                ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
                ["<CR>"] = { "accept", "fallback" },
                ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-e>"] = { "cancel", "fallback" },
                ["<C-b>"] = { "scroll_documentation_up", "fallback" },
                ["<C-f>"] = { "scroll_documentation_down", "fallback" },
            },
            appearance = {
                use_nvim_cmp_as_default = false,
                nerd_font_variant = "mono",
            },
            completion = {
                accept = {
                    auto_brackets = { enabled = true },
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 200,
                },
                list = {
                    selection = { preselect = false, auto_insert = true },
                },
                menu = {
                    draw = {
                        columns = {
                            { "label", "label_description", gap = 1 },
                            { "kind_icon", "kind" },
                        },
                    },
                },
            },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
            cmdline = {
                sources = function()
                    local type = vim.fn.getcmdtype()
                    if type == "/" or type == "?" then
                        return { "buffer" }
                    end
                    if type == ":" then
                        return { "cmdline" }
                    end
                    return {}
                end,
            },
            signature = {
                enabled = true,
            },
        },
    },
}
