return {
    -- Highlight, edit, and navigate code
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function(_, opts)
            -- 1. Tell Treesitter to use Git instead of Curl/Tarball (Fixes your error)
            require('nvim-treesitter.install').prefer_git = true
            
            -- 2. Register the Lean parser manually
            local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
            parser_config.lean = {
                install_info = {
                    url = "https://github.com/Julian/tree-sitter-lean",
                    files = { "src/parser.c", "src/scanner.c" },
                    branch = "main",
                },
            }

            -- 3. Run the standard setup
            require("nvim-treesitter.configs").setup(opts)
        end,
        opts = {
            ensure_installed = {
                "bash",
                "c",
                "c_sharp",
                "diff",
                "html",
                "lua",
                "luadoc",
                "markdown",
                "markdown_inline",
                "query",
                "vim",
                "vimdoc",
                "asm",
                "rust",
                "lean"
            },
            auto_install = true,
            highlight = {
                enable = vim.fn.has('win32') == 0, 
                disable = { "latex" },
                additional_vim_regex_highlighting = { "ruby", "latex" },
            },
            indent = { enable = true, disable = { "ruby" } },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require('treesitter-context').setup {
                enable = true,
            }
        end
    }
}
