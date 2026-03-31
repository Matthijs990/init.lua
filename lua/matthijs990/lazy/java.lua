return {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
        
        -- Helper function to dynamically read the JDK version from build.gradle
        local function get_jdk_from_build_gradle(root_dir)
            local file = io.open(root_dir .. "/build.gradle", "r")
            if file then
                for line in file:lines() do
                    -- Matches: sourceCompatibility = JavaVersion.VERSION_25
                    local version = line:match("sourceCompatibility%s*=%s*.*VERSION_(%d+)")
                    
                    -- Fallback match for: sourceCompatibility = '25' or sourceCompatibility = 25
                    if not version then
                        version = line:match("sourceCompatibility%s*=%s*['\"]?(%d+)['\"]?")
                    end
                    
                    if version then
                        file:close()
                        local constructed_path = "/usr/lib/jvm/java-" .. version .. "-openjdk"
                        -- vim.notify("Parsed from build.gradle: " .. constructed_path, vim.log.levels.INFO)
                        return constructed_path
                    end
                end
                file:close()
            end
            
            -- Absolute fallback if parsing fails
            vim.notify("Could not parse build.gradle, using fallback", vim.log.levels.WARN)
            return "/usr/lib/jvm/java-25-openjdk"
        end
        -- Helper function to dynamically read the JDK path from gradle.properties
        local function get_gradle_java_home(root_dir)
            -- Note: Make sure your file is named gradle.properties, not properties.gradle!
            local file = io.open(root_dir .. "/gradle.properties", "r")
            if file then
                for line in file:lines() do
                    local path = line:match("^org%.gradle%.java%.home%s*=%s*(.+)$")
                    if path then
                        file:close()
                        return path
                    end
                end
                file:close()
            end
            return "/usr/lib/jvm/java-25-openjdk"
        end

        local function setup_jdtls()
            local jdtls = require("jdtls")
            
            -- 1. Identify project root (Removed .git so it doesn't accidentally attach to globaldir)
            local root_dir = require('lspconfig.util').root_pattern("build.gradle", "gradlew")(vim.fn.expand('%:p'))
            if not root_dir or root_dir == "" then 
                vim.notify("JDTLS: Could not find build.gradle or gradlew", vim.log.levels.WARN)
                return 
            end
            
            local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
            local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. project_name

            -- 2. Dynamically fetch the Java path
            local java_home
            if (not get_jdk_from_build_gradle(root_dir)) then
                vim.notify("Failed to parse JDK version from build.gradle, using fallback", vim.log.levels.WARN)
                java_home = get_gradle_java_home(root_dir)
            else 
                java_home = get_jdk_from_build_gradle(root_dir)

            end
            
            -- Debugging popups to verify it's working!
            -- vim.notify("JDTLS Root: " .. root_dir, vim.log.levels.INFO)
            -- vim.notify("JDTLS Java: " .. java_home, vim.log.levels.INFO)
            
            vim.env.JAVA_HOME = java_home

            local config = {
                cmd = { "jdtls", "-data", workspace_dir },
                root_dir = root_dir,
                
                settings = {
                    java = {
                        configuration = { 
                            updateBuildConfiguration = "interactive",
                            runtimes = {
                                {
                                    name = "JavaSE-25",
                                    path = java_home,
                                    default = true,
                                }
                            }
                        },
                        import = { 
                            gradle = { 
                                enabled = true,
                                wrapper = { enabled = true },
                                java = { home = java_home } 
                            } 
                        },
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

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = setup_jdtls,
        })
    end,
}
