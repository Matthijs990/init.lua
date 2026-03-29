return {
    "selimacerbas/markdown-preview.nvim",
    dependencies = { "selimacerbas/live-server.nvim" },
    ft = { "markdown", "mermaid" },
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewRefresh" },
    config = function()
        require("markdown_preview").setup({
            port = 8421,
            open_browser = true,
            debounce_ms = 300,
            mermaid_renderer = "js",
        })

        -- Streamlined export function using the direct mmdc command
        local function export_mmdc(ext)
            local file = vim.fn.expand("%:p")
            local output = vim.fn.expand("%:p:r") .. "." .. ext

            -- Construct the command (shellescape protects against spaces in file paths)
            local cmd = string.format("mmdc -i %s -o %s -b transparent",
                vim.fn.shellescape(file),
                vim.fn.shellescape(output)
            )

            -- Add the 4096x4096 resolution flags specifically for the PNG export
            if ext == "png" then
                cmd = cmd .. " -w 4096 -H 4096"
            end

            -- Optional: If transparent backgrounds look weird in your PDFs, you can force a white background
            if ext == "pdf" then
                cmd = string.format("mmdc -i %s -o %s -b white",
                    vim.fn.shellescape(file),
                    vim.fn.shellescape(output)
                )
            end

            print("Exporting " .. string.upper(ext) .. " via mmdc...")

            -- Run the command asynchronously in the background
            vim.fn.jobstart(cmd, {
                on_exit = function(_, code)
                    if code == 0 then
                        print("Export successful: " .. output)
                    else
                        print("Export failed. Exit code: " .. code)
                    end
                end,
            })
        end

        -- Standard Preview Keybinds
        vim.keymap.set("n", "<leader>mps", "<cmd>MarkdownPreview<cr>", { desc = "Markdown: Start preview" })
        vim.keymap.set("n", "<leader>mpS", "<cmd>MarkdownPreviewStop<cr>", { desc = "Markdown: Stop preview" })
        vim.keymap.set("n", "<leader>mpr", "<cmd>MarkdownPreviewRefresh<cr>", { desc = "Markdown: Refresh preview" })

        -- Direct Diagram Exports
        vim.keymap.set("n", "<leader>mpe", function() export_mmdc("svg") end, { desc = "Markdown: Export SVG" })
        vim.keymap.set("n", "<leader>mpp", function() export_mmdc("png") end, { desc = "Markdown: Export 4K PNG" })
        vim.keymap.set("n", "<leader>mpf", function() export_mmdc("pdf") end, { desc = "Markdown: Export PDF" })
    end,
}
