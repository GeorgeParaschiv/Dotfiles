return {
  "EdenEast/nightfox.nvim",
  priority = 1000, -- ensure it loads early
  config = function()
    vim.cmd("colorscheme carbonfox")
  end,
}

