local map = vim.keymap.set

map("n", "<leader>ln", function()
  local wo = vim.wo
  if wo.number or wo.relativenumber then
      wo.relativenumber = false
      wo.number = false
  else
    wo.number = true
    wo.relativenumber = true
  end
end, { desc = "Toggle hybrid line numbers on/off" })

map("n", "<leader>cf", ":%y+<CR>", { desc = "Copy entire file to system clipboard (+)" })

map("v", "<C-c>", function()
  vim.cmd('normal! "zy')                 -- yank selection -> "z
  local text = vim.fn.getreg("z")
  if not text or #text == 0 then return end
  local job = vim.fn.jobstart({ "tmux", "load-buffer", "-w", "-" }, { stdin = "pipe" })
  if job > 0 then
    vim.fn.chansend(job, text)
    vim.fn.chanclose(job, "stdin")
  end
end, { desc = "Copy via tmux buffer" })
