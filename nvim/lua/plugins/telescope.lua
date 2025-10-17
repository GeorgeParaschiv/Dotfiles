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
  
    local function get_visual_selection()
      local bufnr = 0
      local srow, scol = unpack(vim.api.nvim_buf_get_mark(bufnr, "<"))
      local erow, ecol = unpack(vim.api.nvim_buf_get_mark(bufnr, ">"))
      if srow == 0 or erow == 0 then return "" end
      local lines = vim.api.nvim_buf_get_text(bufnr, srow - 1, scol, erow - 1, ecol + 1, {})
      local text = table.concat(lines, "\n"):gsub("^%s+", ""):gsub("%s+$", ""):gsub("\n+", " ")
      return text
    end

    vim.keymap.set("v", "<leader>fg", function()
      local text = get_visual_selection()
      if text ~= "" then
        builtin.live_grep({
          default_text = text,
          additional_args = function() return { "--fixed-strings" } end,
        })
      end
    end, { desc = "Telescope: Live grep selection", silent = true })
  end,
}

