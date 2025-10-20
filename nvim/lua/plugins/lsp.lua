return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp", -- to advertise completion capabilities to servers
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Mason = easy server installs (use :Mason to manage)
      require("mason").setup({})
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "vue_ls",   -- was 'volar' :contentReference[oaicite:1]{index=1}
          "bashls",
          "jsonls",
          "ts_ls",    -- was 'tsserver' :contentReference[oaicite:2]{index=2}
          "clangd",   -- C/C++
          "pyright",
        },
        handlers = {
          -- default handler
          function(server)
            lspconfig[server].setup({ capabilities = capabilities })
          end,

          -- Lua
          ["lua_ls"] = function()
              local lspconfig = require("lspconfig")
              local util = require("lspconfig.util")
              lspconfig.lua_ls.setup({
                  capabilities = require("cmp_nvim_lsp").default_capabilities(),
                  -- Tell lua_ls what counts as a project root (so it doesn't pick $HOME)
                  root_dir = function(fname)
                      return util.root_pattern(
                          ".luarc.json",
                          ".luarc.jsonc",
                          ".luacheckrc",
                          "stylua.toml",
                          ".git"
                      )(fname) or util.path.dirname(fname)
                  end,
                  settings = {
                      Lua = {
                          runtime = { version = "LuaJIT" },     -- for Neovim
                          diagnostics = { globals = { "vim" } },
                          workspace = {
                              checkThirdParty = false,            -- don’t prompt about third-party
                              library = vim.api.nvim_get_runtime_file("", true), -- Neovim runtime
                          },
                          telemetry = { enable = false },
                      },
                  },
                  single_file_support = true,
              })
          end, 

          -- Vue (Volar)
          ["vue_ls"] = function()
            lspconfig.vue_ls.setup({
              capabilities = capabilities,
              -- Basic setup; vue_ls will own .vue files
            })
          end,

          -- TypeScript/JavaScript (do NOT attach to .vue to avoid conflicts)
          ["ts_ls"] = function()
            lspconfig.ts_ls.setup({
              capabilities = capabilities,
              filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
            })
          end,

          -- C/C++ (clangd)
          ["clangd"] = function()
            lspconfig.clangd.setup({
              capabilities = capabilities,
            })
          end,

          -- Python
          ["pyright"] = function()
            lspconfig.pyright.setup({
              capabilities = capabilities,
            })
          end,
        },
      })

      -- LSP keymaps (buffer-local)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local o = { buffer = ev.buf, silent = true, noremap = true }
          vim.keymap.set("n", "K",  vim.lsp.buf.hover,          o)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition,     o)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration,    o)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, o)
          vim.keymap.set("n", "gr", vim.lsp.buf.references,     o)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,     o)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, o)
        end,
      })
    end,
  },
}

