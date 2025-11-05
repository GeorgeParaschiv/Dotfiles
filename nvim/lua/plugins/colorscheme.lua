return {
  "EdenEast/nightfox.nvim",
  priority = 1000,
  config = function()
    local ok, _ = pcall(vim.cmd, "colorscheme carbonfox")
    if not ok then
      vim.notify("Failed to load colorscheme 'carbonfox'. Using default.", vim.log.levels.WARN)
    end
  end,
}

