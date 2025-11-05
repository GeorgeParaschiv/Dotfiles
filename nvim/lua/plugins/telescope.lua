return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = function() return vim.fn.executable("make") == 1 end },
  },
  config = function()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")
    local action_layout = require("telescope.actions.layout")
    local utils = require("telescope.utils")

    local function repo_root_or_cwd()
      local ok, out = pcall(utils.get_os_command_output, { "git", "rev-parse", "--show-toplevel" })
      if ok and out and out[1] and #out[1] > 0 then return out[1] end
      return vim.loop.cwd()
    end

    local function common_rg_args()
      return { "--max-columns=200", "--max-columns-preview", "--max-filesize", "1M" }
    end

    local function get_visual_selection()
      local _, ls, cs = unpack(vim.fn.getpos("'<"))
      local _, le, ce = unpack(vim.fn.getpos("'>"))
      if ls == 0 or le == 0 then return "" end
      local lines = vim.api.nvim_buf_get_lines(0, ls - 1, le, false)
      if #lines == 0 then return "" end
      lines[1] = string.sub(lines[1], cs, -1)
      lines[#lines] = string.sub(lines[#lines], 1, ce)
      return table.concat(lines, " "):gsub("%s+", " ")
    end

    local function live_grep_git_root(opts)
      opts = opts or {}
      opts.cwd = repo_root_or_cwd()
      opts.additional_args = common_rg_args
      builtin.live_grep(opts)
    end

    local function grep_string_git_root(opts)
      opts = opts or {}
      opts.cwd = repo_root_or_cwd()
      opts.additional_args = common_rg_args
      builtin.grep_string(opts)
    end

    telescope.setup({
      defaults = {
        preview = { treesitter = false },
        mappings = {
          i = { ["<M-p>"] = action_layout.toggle_preview },
          n = { ["<M-p>"] = action_layout.toggle_preview },
        },
        file_ignore_patterns = {
          "%.git/", "node_modules/", "dist/", "build/", "target/", "coverage/",
          ".venv/", ".tox/", "vendor/", "Pods/", "__pycache__/",
          "%.lock", "%.min%.js", "%.min%.css",
        },
        vimgrep_arguments = {
          "rg", "--color=never", "--no-heading", "--with-filename",
          "--line-number", "--column", "--smart-case", "--hidden", "--trim",
        },
      },
      pickers = {
        live_grep   = { previewer = false }, -- toggle with Alt-p
        grep_string = { previewer = false }, -- toggle with Alt-p
      },
    })

    pcall(telescope.load_extension, "fzf")

    -- Find files
    vim.keymap.set("n", "<leader>ff", function()
      builtin.find_files({ hidden = true })
    end, { desc = "Find files", silent = true })

    -- Live grep
    vim.keymap.set("n", "<leader>fg", function()
      live_grep_git_root({})
    end, { desc = "Live grep", silent = true })

    -- Grep string
    vim.keymap.set("n", "<leader>fs", function()
      grep_string_git_root({})
    end, { desc = "Grep string", silent = true })

    vim.keymap.set("v", "<leader>fs", function()
      local text = get_visual_selection()
      grep_string_git_root({ search = text ~= "" and text or nil })
    end, { desc = "Grep selection", silent = true })

    -- Old files
    vim.keymap.set("n", "<leader>fr", function()
      builtin.oldfiles()
    end, { desc = "Old files", silent = true })
  end,
}

