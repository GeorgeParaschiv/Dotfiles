return {
  "romgrk/barbar.nvim",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  init = function()
    vim.g.barbar_auto_setup = false
  end,
  config = function()
    require("barbar").setup({
      animation = false,
      clickable = true,

      maximum_padding = 4,   -- default 1
      minimum_padding = 2,   -- default 1
      minimum_length  = 14,  -- ensure a wider minimum tab
      maximum_length  = 30,

      icons = {
        separator = { left = "▎", right = "" },
        diagnostics = {
          [vim.diagnostic.severity.ERROR] = { enabled = true },
          [vim.diagnostic.severity.WARN]  = { enabled = true },
        },
        buffer_index = true,  
        current = { buffer_index = true },
      },

      sidebar_filetypes = { ["neo-tree"] = true },
    })

    local map = vim.keymap.set
    map("n", "<Tab>",     "<Cmd>BufferNext<CR>",     { desc = "Next buffer" })
    map("n", "<S-Tab>",   "<Cmd>BufferPrevious<CR>", { desc = "Prev buffer" })
    map("n", "<leader>bc","<Cmd>BufferClose<CR>",    { desc = "Close buffer" })
  end,
}


