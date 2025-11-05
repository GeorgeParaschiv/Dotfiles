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
end, { desc = "Toggle line numbers" })

map("n", "<leader>cf", ":%y+<CR>", { desc = "Copy file to clipboard" })

map("v", "<C-c>", function()
  -- Yank the visual selection to register "z"
  vim.cmd('normal! "zy')
  local text = vim.fn.getreg("z")
  if not text or #text == 0 then
    return
  end
  
  -- Copy to clipboard
  local cmd
  if vim.fn.executable("clip.exe") == 1 then
    -- WSL
    cmd = { "clip.exe" }
  elseif vim.fn.executable("wl-copy") == 1 then
    -- Wayland
    cmd = { "wl-copy" }
  elseif vim.fn.executable("xclip") == 1 then
    -- X11
    cmd = { "xclip", "-selection", "clipboard" }
  else
    vim.notify("No clipboard tool found. Install clip.exe (WSL), wl-copy (Wayland), or xclip (X11)", vim.log.levels.WARN)
    return
  end
  
  vim.fn.system(cmd, text)
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to copy to clipboard (exit code: " .. vim.v.shell_error .. ")", vim.log.levels.ERROR)
  end
end, { noremap = true, silent = true, desc = "Copy to clipboard" })
