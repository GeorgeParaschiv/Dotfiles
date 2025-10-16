-- lua/plugins/neo-tree.lua
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- optional but recommended
    "MunifTanjim/nui.nvim",
    -- optional: better window picking when opening files from the tree
    { "s1n7ax/nvim-window-picker", opts = { hint = "floating-big-letter" } },
  },
  init = function()
    -- recommended by neo-tree when hijacking netrw
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
    { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Reveal current file" },
  },
  opts = {
    close_if_last_window = true,
    popup_border_style = "rounded",
    -- keep it simple; don't touch global statusline/winbar
    enable_git_status = true,
    enable_diagnostics = true,
    default_component_configs = {
      indent = { padding = 1 },
      icon = { folder_closed = "", folder_open = "", folder_empty = "" },
      git_status = { symbols = { added = "", modified = "", deleted = "" } },
    },
    filesystem = {
      follow_current_file = { enabled = true },
      hijack_netrw_behavior = "open_default",
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = true,
      },
    },
    window = {
      position = "left",
      width = 34,
      mappings = {
        ["<space>"] = "toggle_node",
        ["<cr>"] = "open",
        ["o"] = "open",
        ["s"] = "open_split",
        ["v"] = "open_vsplit",
        ["R"] = "refresh",
        ["q"] = "close_window",
      },
    },
  },
  config = function(_, opts)
    require("neo-tree").setup(opts)

    -- Open the explorer by default on startup (but don't steal a real file buffer)
    local function open_neotree_on_start()
      -- Only open if we're in a directory or no file was provided
      if vim.fn.argc() == 0 then
        vim.cmd("Neotree show")
      else
        local arg = vim.fn.argv(0)
        if arg and vim.fn.isdirectory(arg) == 1 then
          vim.cmd("Neotree show")
        end
      end
    end
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = open_neotree_on_start,
    })
  end,
}

