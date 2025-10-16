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
      icons = { diagnostics = { [vim.diagnostic.severity.ERROR] = { enabled = true },
                                 [vim.diagnostic.severity.WARN]  = { enabled = true } } },
      sidebar_filetypes = { NvimTree = true, undotree = true, ["neo-tree"] = true },
    })
    -- tiny, useful keys (optional)
    local map = vim.keymap.set
    map("n", "<Tab>",     "<Cmd>BufferNext<CR>",     { desc = "Next buffer" })
    map("n", "<S-Tab>",   "<Cmd>BufferPrevious<CR>", { desc = "Prev buffer" })
    map("n", "<leader>bc","<Cmd>BufferClose<CR>",    { desc = "Close buffer" })
  end,
}

