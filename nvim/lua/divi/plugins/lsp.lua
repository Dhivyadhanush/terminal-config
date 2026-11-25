-- DIVI · language servers (completion, hover, go-to-def, rename, diagnostics)
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Web / TypeScript
        ts_ls = {},
        html = {},
        cssls = {},
        tailwindcss = {},
        emmet_language_server = {},
        -- Data / config files
        jsonls = {},
        yamlls = {},
        bashls = {},
        -- Python
        pyright = {},
        -- Lua (this config)
        lua_ls = {},
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
        "ts_ls",
        "html",
        "cssls",
        "tailwindcss",
        "jsonls",
        "yamlls",
        "bashls",
        "pyright",
      },
    },
  },
  {
    -- Parameter names / types shown inline, like IntelliJ
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
          end
        end,
      })
    end,
  },
}
