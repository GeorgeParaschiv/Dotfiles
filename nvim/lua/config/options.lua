vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.o.termguicolors = true

vim.opt.mouse = "a"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "sh", "bash" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})
