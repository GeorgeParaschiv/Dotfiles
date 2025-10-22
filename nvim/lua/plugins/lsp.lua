-- nvim/lua/plugins/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- de-dupe duplicate definition results
      do
        local def = vim.lsp.handlers["textDocument/definition"]
        vim.lsp.handlers["textDocument/definition"] = function(err, result, ctx, conf)
          if vim.tbl_islist(result) then
            local seen, uniq = {}, {}
            for _, loc in ipairs(result) do
              local uri = loc.uri or loc.targetUri
              local rng = loc.range or loc.targetRange
              if uri and rng then
                local fname = vim.uri_to_fname(uri)
                local real  = vim.loop.fs_realpath(fname) or fname
                local key   = real .. ":" .. rng.start.line
                if not seen[key] then seen[key] = true; table.insert(uniq, loc) end
              end
            end
            result = uniq
          end
          return def(err, result, ctx, conf)
        end
      end

      require("mason").setup({})
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "vue_ls",   -- Vue (aka Volar)
          "bashls",
          "jsonls",
          "ts_ls",    -- TypeScript/JS
          "clangd",
          "pyright",
        },
        handlers = {
          function(server)
            lspconfig[server].setup({ capabilities = capabilities })
          end,

          lua_ls = function()
            local util = require("lspconfig.util")
            lspconfig.lua_ls.setup({
              capabilities = capabilities,
              root_dir = function(fname)
                return util.root_pattern(".luarc.json", ".luarc.jsonc", ".luacheckrc", "stylua.toml", ".git")(fname)
                  or util.path.dirname(fname)
              end,
              settings = {
                Lua = {
                  runtime = { version = "LuaJIT" },
                  diagnostics = { globals = { "vim" } },
                  workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
                  telemetry = { enable = false },
                },
              },
              single_file_support = true,
            })
          end,

          ts_ls = function()
            lspconfig.ts_ls.setup({
              capabilities = capabilities,
              filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
            })
          end,

          clangd = function()
            local util = require("lspconfig.util")
            lspconfig.clangd.setup({
              capabilities = vim.tbl_deep_extend("force", {}, capabilities, { offsetEncoding = { "utf-16" } }),
              cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--completion-style=detailed",
                "--header-insertion=iwyu",
                "--fallback-style=LLVM",
                "--cross-file-rename",
                "--query-driver=/usr/bin/clang*,/usr/bin/gcc*",
              },
              root_dir = function(fname)
                return util.root_pattern("compile_commands.json", "compile_flags.txt", ".git")(fname)
                  or util.path.dirname(fname)
              end,
              single_file_support = true,
            })
          end,
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local o = { buffer = ev.buf, silent = true, noremap = true }
          vim.keymap.set("n", "K",  vim.lsp.buf.hover,          o)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition,     o)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration,    o)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, o)
          vim.keymap.set("n", "gr", vim.lsp.buf.references,     o)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,      o)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, o)
        end,
      })
    end,
  },
}

