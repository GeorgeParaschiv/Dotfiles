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
  -- Yank the visual selection to register "z"
  vim.cmd('normal! "zy')
  local text = vim.fn.getreg("z")
  if not text or #text == 0 then
    return
  end
  
  -- Try WSL clipboard integration first (clip.exe), then fallback to Linux clipboard tools
  local cmd
  if vim.fn.executable("clip.exe") == 1 then
    -- WSL: use Windows clipboard
    cmd = { "clip.exe" }
  elseif vim.fn.executable("wl-copy") == 1 then
    -- Wayland: use wl-copy
    cmd = { "wl-copy" }
  elseif vim.fn.executable("xclip") == 1 then
    -- X11: use xclip
    cmd = { "xclip", "-selection", "clipboard" }
  else
    vim.notify("No clipboard tool found. Install clip.exe (WSL), wl-copy (Wayland), or xclip (X11)", vim.log.levels.WARN)
    return
  end
  
  -- Execute clipboard command with text as stdin
  vim.fn.system(cmd, text)
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to copy to clipboard (exit code: " .. vim.v.shell_error .. ")", vim.log.levels.ERROR)
  end
end, { noremap = true, silent = true, desc = "Copy selection to system clipboard" })
