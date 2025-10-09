local map = vim.keymap.set

map("n", "<leader>ln", function()
  if vim.wo.number then
    vim.wo.number = false
  else
    vim.wo.number = true
    vim.wo.relativenumber = false
  end
end, { desc = "Toggle absolute line numbers on/off" })

map("n", "<leader>cf", ":%y+<CR>", { desc = "Copy entire file to system clipboard (+)" })
