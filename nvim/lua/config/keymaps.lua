local map = vim.keymap.set

-- Toggle line numbers
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

-- Copy file to clipboard
map("n", "<leader>cf", ":%y+<CR>", { desc = "Copy file to clipboard" })

-- Copy to clipboard
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

-- New buffer
map("n", "<C-n>", function()
  vim.cmd("enew")
end, { desc = "New buffer" })

-- Save buffer with file picker
map("n", "<C-s>", function()
  local buf_name = vim.api.nvim_buf_get_name(0)
  if buf_name ~= "" and vim.fn.filereadable(buf_name) == 1 then
    vim.cmd("write")
  else
    local ok, builtin = pcall(require, "telescope.builtin")
    if ok then
      vim.ui.input({ prompt = "Save as: ", default = buf_name }, function(input)
        if input and input ~= "" then
          vim.cmd("write " .. vim.fn.fnameescape(input))
        end
      end)
    else
      vim.cmd("browse write")
    end
  end
end, { desc = "Save buffer" })

-- Save all buffers
map("n", "<C-S>", function()
  vim.cmd("wa")
end, { desc = "Save all buffers" })

-- Exit terminal mode
map("t", "<esc>", "<C-\\><C-N>", { desc = "Exit terminal mode" })

-- Force quit neovim
vim.api.nvim_create_user_command("X", function()
  vim.cmd("qa!")
end, { desc = "Force quit neovim" })
