return {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        local jdtls = require("jdtls")
        local mason_registry = require("mason-registry")

        -- Ensure mason registry is refreshed
        mason_registry.refresh()

        -- Check if jdtls is installed
        if not mason_registry.is_installed("jdtls") then
            vim.notify("jdtls is not installed. Run :MasonInstall jdtls", vim.log.levels.WARN)
            return
        end

        -- Find jdtls installation
        local jdtls_path = mason_registry.get_package("jdtls"):get_install_path()
        local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

        -- Detect OS for config folder
        local config_dir
        if vim.fn.has("win32") == 1 then
            config_dir = jdtls_path .. "/config_win"
        elseif vim.fn.has("mac") == 1 then
            config_dir = jdtls_path .. "/config_mac"
        else
            config_dir = jdtls_path .. "/config_linux"
        end

        -- Workspace directory (unique per project)
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

        local config = {
            cmd = {
                "java",
                "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                "-Dosgi.bundles.defaultStartLevel=4",
                "-Declipse.product=org.eclipse.jdt.ls.core.product",
                "-Dlog.protocol=true",
                "-Dlog.level=ALL",
                "-Xmx1g",
                "--add-modules=ALL-SYSTEM",
                "--add-opens", "java.base/java.util=ALL-UNNAMED",
                "--add-opens", "java.base/java.lang=ALL-UNNAMED",
                "-jar", launcher_jar,
                "-configuration", config_dir,
                "-data", workspace_dir,
            },
            root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
            settings = {
                java = {
                    signatureHelp = { enabled = true },
                    contentProvider = { preferred = "fernflower" },
                    completion = {
                        favoriteStaticMembers = {
                            "org.junit.Assert.*",
                            "org.junit.jupiter.api.Assertions.*",
                            "org.mockito.Mockito.*",
                        },
                    },
                    sources = {
                        organizeImports = {
                            starThreshold = 9999,
                            staticStarThreshold = 9999,
                        },
                    },
                    codeGeneration = {
                        toString = {
                            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                        },
                        hashCodeEquals = {
                            useJava7Objects = true,
                        },
                        useBlocks = true,
                    },
                },
            },
            init_options = {
                bundles = {},
            },
        }

        -- Start jdtls when opening Java files
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = function()
                jdtls.start_or_attach(config)
            end,
        })
    end,
}

