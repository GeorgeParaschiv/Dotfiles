return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      theme = "auto",
      globalstatus = true, -- one statusline for the whole screen
      disabled_filetypes = {
        statusline = { "NvimTree" }, -- don't render lualine in the tree window
        winbar     = { "NvimTree" }, -- if you use lualine winbar, skip it for tree
      },
    },
    extensions = { "nvim-tree" }, -- lualine knows how to play nice with the tree
  },
}

