-- Project view, file explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Move selected lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- pastes over selecting without copying
vim.keymap.set("x", "<leader>p", [["_dP]])
-- deleted without copying to register
vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d")

-- format current buffer
vim.keymap.set("n", "<leader>f", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format document" })

-- start search and replace for word under cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set("v", "<C-f>", [[y/\V<C-R>=escape(@",'/\')<CR><CR>]], { desc = "Search forward for selected text" })
vim.keymap.set("v", "#", [[y?\V<C-R>=escape(@",'/\')<CR><CR>]], { desc = "Search backward for selected text" })

-- LSP code actions
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'LSP Code Action' })


-- remove search highlight
vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Remove search highlight" })

-- Insert code block with triple backticks (Markdown/Typst)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "typst" },
  callback = function()
    -- Insert code block in normal mode
    vim.keymap.set("n", "<leader>cb", function()
      local line = vim.api.nvim_win_get_cursor(0)[1]
      vim.api.nvim_buf_set_lines(0, line, line, false, { "```", "", "```" })
      vim.api.nvim_win_set_cursor(0, { line + 1, 0 })
      vim.cmd("startinsert!")
    end, { buffer = true, desc = "Insert code block" })
  end
})
