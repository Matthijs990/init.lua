return {
    "iamkarasik/sonarqube.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    event = "InsertLeave",
    config = function()
        -- Filter out sonarqube notifications
        local original_notify = vim.notify
        vim.notify = function(msg, level, opts)
            if type(msg) == "string" and (msg:lower():match("sonar") or msg:lower():match("analyzing")) then
                return
            end
            return original_notify(msg, level, opts)
        end

        require("sonarqube").setup({
            -- Configure your SonarQube server URL and token here
            -- url = "https://your-sonarqube-server.com",
            -- token = "your-sonarqube-token",
        })
    end,
}
