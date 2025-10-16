return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local builtin = require("telescope.builtin")

    vim.keymap.set("n", "<leader>ff", function()
      builtin.find_files({ hidden = true })
    end, { desc = "Telescope: Find files", silent = true })

    vim.keymap.set("n", "<leader>fg", function()
      builtin.live_grep()
    end, { desc = "Telescope: Live grep", silent = true })
  end,
}

