return {
  "mfussenegger/nvim-lint",
  config = function()
    local lint = require("lint")

    -- Register luacheck for Lua files
    lint.linters_by_ft = {
      lua = { "luacheck" },
    }

   -- Only create the autocmd if the 'luacheck' binary exists
    if vim.fn.executable("luacheck") == 1 then
      local grp = vim.api.nvim_create_augroup("LintLuacheckOnSave", { clear = true })

      -- Run luacheck automatically on save for Lua files
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = grp,
        pattern = "*.lua",
        callback = function()
          -- Explicitly run the luacheck linter; no errors if it exits non-zero
          pcall(lint.try_lint, "luacheck")
        end,
      })
    end

    -- Keymap: show diagnostics in a floating window
    vim.keymap.set("n", "<leader>d", function()
      vim.diagnostic.open_float(nil, { focus = false, scope = "line" })
    end, { desc = "Show diagnostics under cursor" })
  end,
}

