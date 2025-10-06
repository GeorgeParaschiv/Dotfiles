local M = {}

function M.setup()
  local lint = require("lint")

  -- Register luacheck for Lua files
  lint.linters_by_ft = {
    lua = { "luacheck" },
  }

  -- Run lint automatically on save
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function()
      lint.try_lint()
    end,
  })

  -- Keymap: show diagnostics in a floating window
  vim.keymap.set("n", "<leader>d", function()
    vim.diagnostic.open_float(nil, { focus = false, scope = "line" })
  end, { desc = "Show diagnostics under cursor" })

end

return M
