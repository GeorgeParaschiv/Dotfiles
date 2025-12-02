return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
    { "s1n7ax/nvim-window-picker", opts = { hint = "floating-big-letter" } },
  },
  init = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  keys = {
    { "<leader>e", "<cmd>Neotree toggle focus<cr>", desc = "Toggle explorer" },
    { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Reveal file" },
  },
  opts = {
    close_if_last_window = true,
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,
    default_component_configs = {
      indent = { padding = 1 },
      icon = { folder_closed = "", folder_open = "", folder_empty = "" },
      git_status = { symbols = { added = "", modified = "", deleted = "" } },
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
        ["<cr>"] = "open_nofocus",
        ["l"] = "open_nofocus",
        ["o"] = "open",
        ["s"] = "open_split",
        ["v"] = "open_vsplit",
        ["R"] = "refresh",
        ["q"] = "close_window",
        ["<leader>e"] = "close_window",
        ["<Tab>"] = "focus_next_window",
      },
    },
    commands = {
      open_nofocus = function(state)
        local node = state.tree:get_node()
        local commands = require("neo-tree.sources.filesystem.commands")
        if node.type == "directory" then
          commands.toggle_node(state)
        else
          local path = node:get_id()
          local bufnr = vim.fn.bufnr(path)
          local is_open = bufnr ~= -1 and vim.fn.bufloaded(bufnr) == 1
          
          commands.open(state)
          
          if is_open then
            -- File is already open, focus it
            vim.defer_fn(function()
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == bufnr then
                  vim.api.nvim_set_current_win(win)
                  return
                end
              end
            end, 10)
          else
            -- New file, keep focus in neo-tree
            vim.schedule(function()
              vim.cmd("Neotree focus")
            end)
          end
        end
      end,
      focus_next_window = function()
        vim.cmd("wincmd w")
      end,
    },
  },
  config = function(_, opts)
    require("neo-tree").setup(opts)

    -- Open neo-tree on startup when no file is provided
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      nested = true,
      callback = function()
        if vim.fn.argc() == 0 or (vim.fn.argv(0) and vim.fn.isdirectory(vim.fn.argv(0)) == 1) then
          vim.cmd("Neotree focus")
        end
      end,
    })
  end,
}
