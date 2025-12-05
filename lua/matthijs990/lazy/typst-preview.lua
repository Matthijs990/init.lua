return {
  'chomosuke/typst-preview.nvim',
  lazy = false, -- or ft = 'typst'
  version = '1.*',
  opts = {}, -- lazy.nvim will implicitly calls `setup {}`
  config = function()
    require('typst-preview').setup({})
    
    -- Create TypstExport command for PDF export
    vim.api.nvim_create_user_command('TypstExport', function()
      local buf = vim.api.nvim_get_current_buf()
      local filepath = vim.api.nvim_buf_get_name(buf)
      
      if filepath == "" then
        vim.notify("No file open", vim.log.levels.ERROR)
        return
      end
      
      if not vim.endswith(filepath, ".typ") then
        vim.notify("Not a Typst file", vim.log.levels.WARN)
        return
      end
      
      local output_path = filepath:gsub("%.typ$", ".pdf")
      
      vim.notify("Exporting to PDF...", vim.log.levels.INFO)
      
      vim.fn.jobstart({ "typst", "compile", filepath, output_path }, {
        on_exit = function(_, exit_code)
          if exit_code == 0 then
            vim.notify("Successfully exported to: " .. output_path, vim.log.levels.INFO)
          else
            vim.notify("Export failed with exit code: " .. exit_code, vim.log.levels.ERROR)
          end
        end,
        on_stderr = function(_, data)
          if data and #data > 0 then
            for _, line in ipairs(data) do
              if line ~= "" then
                vim.notify("Typst: " .. line, vim.log.levels.WARN)
              end
            end
          end
        end,
      })
    end, {
      desc = "Export current Typst file to PDF"
    })

    -- Add keybinding for Typst files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "typst",
      callback = function()
        vim.keymap.set("n", "<leader>te", ":TypstExport<CR>", 
          { buffer = true, desc = "Typst Export to PDF" })
      end
    })
  end,
}