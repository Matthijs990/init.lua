return {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    config = function()
        local jdtls = require('jdtls')

        -- Disable diagnostics while in insert mode
        vim.diagnostic.config({ update_in_insert = false })

        -- Workspace directory (unique per project)
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
        local workspace_dir = vim.fn.stdpath('data') .. '/jdtls-workspace/' .. project_name

        -- Detect OS for config folder
        local config_dir
        if vim.fn.has('win32') == 1 then
            config_dir = vim.fn.stdpath('data') .. '/mason/packages/jdtls/config_win'
        elseif vim.fn.has('mac') == 1 then
            config_dir = vim.fn.stdpath('data') .. '/mason/packages/jdtls/config_mac'
        else
            config_dir = vim.fn.stdpath('data') .. '/mason/packages/jdtls/config_linux'
        end

        local config = {
            cmd = {
                'java',
                '-Declipse.application=org.eclipse.jdt.ls.core.id1',
                '-Dosgi.bundles.defaultStartLevel=4',
                '-Declipse.product=org.eclipse.jdt.ls.core.product',
                '-Dlog.protocol=true',
                '-Dlog.level=ALL',
                '-Xmx1g',
                '--add-modules=ALL-SYSTEM',
                '--add-opens', 'java.base/java.util=ALL-UNNAMED',
                '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
                '-jar', vim.fn.glob(vim.fn.stdpath('data') .. '/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
                '-configuration', config_dir,
                '-data', workspace_dir,
            },
            root_dir = jdtls.setup.find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }),
            flags = {
                debounce_text_changes = 1000,
            },
            handlers = {
                -- Only show progress messages when NOT in insert mode
                ['$/progress'] = function(err, result, ctx)
                    if vim.fn.mode() == 'i' then
                        return  -- Ignore in insert mode
                    end
                    -- Use default handler when not in insert mode
                    vim.lsp.handlers['$/progress'](err, result, ctx)
                end,
                ['language/status'] = function(err, result, ctx)
                    if vim.fn.mode() == 'i' then
                        return  -- Ignore in insert mode
                    end
                    vim.notify(result.message, vim.log.levels.INFO, { title = 'jdtls' })
                end,
            },
            settings = {
                java = {
                    signatureHelp = { enabled = true },
                    contentProvider = { preferred = 'fernflower' },
                    completion = {
                        favoriteStaticMembers = {
                            'org.junit.Assert.*',
                            'org.junit.jupiter.api.Assertions.*',
                            'org.mockito.Mockito.*',
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
                            template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
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

        jdtls.start_or_attach(config)
    end,
}
