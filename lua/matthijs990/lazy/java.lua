return {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
        local function setup_jdtls()
            local jdtls = require("jdtls")
            
            -- 1. Identify project root
            local root_dir = jdtls.setup.find_root({ "gradlew", "build.gradle", ".git" })
            if root_dir == "" then return end
            
            local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
            local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. project_name

            local config = {
                -- If 'jdtls' isn't in your path, replace with absolute path to the executable
                cmd = { "jdtls", "-data", workspace_dir },
                root_dir = root_dir,
                
                settings = {
                    java = {
                        -- Required for Java 25 / bleeding edge support
                        configuration = { updateBuildConfiguration = "interactive" },
                        import = { gradle = { enabled = true } },
                        contentProvider = { preferred = 'fernflower' },
                    },
                },
                on_attach = function(client, bufnr)
                    local opts = { buffer = bufnr }
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', '<leader>ju', jdtls.update_project_config, { desc = "Update Gradle" })
                end,
            }
            jdtls.start_or_attach(config)
        end

        -- Attach to Java files
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = setup_jdtls,
        })
    end,
}
