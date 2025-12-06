return {
  'chomosuke/typst-preview.nvim',
  lazy = false, -- or ft = 'typst'
  root_dir = vim.fn.getcwd(),
  version = '1.*',
  opts = {}, -- lazy.nvim will implicitly calls `setup {}`
  config = function()
    require('typst-preview').setup({})
    
    -- Helper function for Typst exports
    local function typst_export(output_extension, description)
      return function()
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
        
        local output_path = filepath:gsub("%.typ$", "." .. output_extension)
        
        vim.notify("Exporting to " .. output_extension:upper() .. "...", vim.log.levels.INFO)
        
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
      end
    end

    -- Create export commands
    vim.api.nvim_create_user_command('TypstExport', typst_export("pdf", "PDF"), {
      desc = "Export current Typst file to PDF"
    })

    vim.api.nvim_create_user_command('TypstToPng', typst_export("png", "PNG"), {
      desc = "Export current Typst file to PNG"
    })

    vim.api.nvim_create_user_command('TypstToSvg', typst_export("svg", "SVG"), {
      desc = "Export current Typst file to SVG"
    })

    -- Add keybinding only for PDF export
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "typst",
      callback = function()
        vim.keymap.set("n", "<leader>te", ":TypstExport<CR>", 
          { buffer = true, desc = "Typst Export to PDF" })
      end
    })
  end,
}