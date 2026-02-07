return {
    "https://gitlab.com/schrieveslaach/sonarlint.nvim",
    ft = { "java" },
    dependencies = {
        "neovim/nvim-lspconfig",
    },
    config = function()
        require("sonarlint").setup({
            server = {
                cmd = {
                    "sonarlint-language-server",
                    "-stdio",
                    "-analyzers",
                    vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjava.jar"),
                },
            },
            filetypes = {
                "java",
            },
        })
    end,
}

