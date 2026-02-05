return {
    "iamkarasik/sonarqube.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        require("sonarqube").setup({
            -- Configure your SonarQube server URL and token here
            -- url = "https://your-sonarqube-server.com",
            -- token = "your-sonarqube-token",
            silent = true,
        })
    end,
}

