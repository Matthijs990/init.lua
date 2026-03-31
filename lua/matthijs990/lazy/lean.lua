return {
  'Julian/lean.nvim',
  event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },
  dependencies = {
    'neovim/nvim-lspconfig',
    'nvim-lua/plenary.nvim',
    'hrsh7th/nvim-cmp',
  },
  opts = {
    -- This line enables the default <LocalLeader> mappings
    mappings = true,
    infoview = {
      auto_open = true,
    },
    lsp = {
      -- You can still keep custom logic here if you want
      on_attach = function(client, bufnr)
        -- The defaults will already be active, 
        -- but you can add extra ones here if needed.
      end,
    },
  }
}
