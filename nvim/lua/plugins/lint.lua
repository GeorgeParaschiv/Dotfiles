return {
  "mfussenegger/nvim-lint",
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      lua = { "luacheck" },
    }

    if vim.fn.executable("luacheck") == 1 then
      local grp = vim.api.nvim_create_augroup("LintLuacheckOnSave", { clear = true })

      vim.api.nvim_create_autocmd("BufWritePost", {
        group = grp,
        pattern = "*.lua",
        callback = function()
          pcall(lint.try_lint, "luacheck")
        end,
      })
    end

    vim.keymap.set("n", "<leader>d", function()
      vim.diagnostic.open_float(nil, { focus = false, scope = "line" })
    end, { desc = "Show diagnostics" })
  end,
}

