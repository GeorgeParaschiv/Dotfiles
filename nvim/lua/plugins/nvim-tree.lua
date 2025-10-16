return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false, -- load at startup so we can open by default
  dependencies = { "nvim-tree/nvim-web-devicons" },

  -- Disable netrw completely (recommended by nvim-tree)
  init = function()
    vim.g.loaded = 1
    vim.g.loaded_netrwPlugin = 1
  end,

  keys = {
    { "<leader>e",  "<cmd>NvimTreeToggle<cr>",   desc = "Explorer: toggle" },
    { "<leader>E",  "<cmd>NvimTreeFocus<cr>",    desc = "Explorer: focus" },
    { "<leader>fr", "<cmd>NvimTreeFindFile<cr>", desc = "Explorer: reveal current file" },
  },

  opts = {
    hijack_cursor = true,
    sync_root_with_cwd = true,
    update_focused_file = { enable = true, update_root = true },

    view = {
      side = "left",
      width = 32,
      preserve_window_proportions = true,
    },

    renderer = {
      group_empty = true,
      highlight_git = true,
      indent_markers = { enable = true },
      -- If your font icons aren’t ready yet, flip these to false:
      icons = { show = { file = true, folder = true, folder_arrow = true, git = true } },
      -- Show just the folder name for the root label
      root_folder_label = ":t",
    },

    filters = {
      dotfiles = false,
      git_ignored = false,
    },

    git = { enable = true, ignore = false },
  },

  config = function(_, opts)
    require("nvim-tree").setup(opts)

    -- Open explorer by default on startup (side-by-side)
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        require("nvim-tree.api").tree.open()
      end,
    })

    -- Put a simple title at the top of the explorer window
    -- (uses Neovim's winbar so it stays in the tree window only)
    local function set_tree_winbar()
      -- Only apply to NvimTree buffers
      if vim.bo.filetype == "NvimTree" then
        -- Minimal text; add spaces so it looks like a badge
        vim.opt_local.winbar = "  NvimTree  "
      end
    end

    vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinNew" }, {
      pattern = { "NvimTree" },
      callback = set_tree_winbar,
    })
  end,
}

