-- import lspconfig plugin safely
local lspconfig_status, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status then
  return
end

-- import lspconfig/util plugin safely
local lspconfig_util_status, util = pcall(require, "lspconfig/util")
if not lspconfig_util_status then
  return
end

-- import cmp-nvim-lsp plugin safely
local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_nvim_lsp_status then
  return
end

-- import typescript plugin safely
local typescript_setup, typescript = pcall(require, "typescript")
if not typescript_setup then
  return
end

-- import ccls.nvim plugin safely
local ccls_setup, ccls = pcall(require, "ccls")
if not ccls_setup then
  return
end

local keymap = vim.keymap -- for conciseness

-- enable keybinds only for when lsp server available
local on_attach = function(client, bufnr)
  -- keybind options
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- set keybinds
  keymap.set("n", "gf", "<cmd>Lspsaga lsp_finder<CR>", opts) -- show definition, references
  keymap.set("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts) -- got to declaration
  keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts) -- see definition and make edits in window
  keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts) -- go to implementation
  keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts) -- see available code actions
  keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts) -- smart rename
  keymap.set("n", "<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", opts) -- show  diagnostics for line
  keymap.set("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts) -- show diagnostics for cursor
  keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts) -- jump to previous diagnostic in buffer
  keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts) -- jump to next diagnostic in buffer
  keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts) -- show documentation for what is under cursor
  keymap.set("n", "<leader>o", "<cmd>LSoutlineToggle<CR>", opts) -- see outline on right hand side

  -- typescript specific keymaps (e.g. rename file and update imports)
  if client.name == "tsserver" then
    keymap.set("n", "<leader>rf", ":TypescriptRenameFile<CR>") -- rename file and update imports
    keymap.set("n", "<leader>oi", ":TypescriptOrganizeImports<CR>") -- organize imports (not in youtube nvim video)
    keymap.set("n", "<leader>ru", ":TypescriptRemoveUnused<CR>") -- remove unused variables (not in youtube nvim video)
  end
end

-- used to enable autocompletion (assign to every lsp server config)
local capabilities = cmp_nvim_lsp.default_capabilities()

-- Change the Diagnostic symbols in the sign column (gutter)
-- (not in youtube nvim video)
local signs = { Error = " ", Warn = " ", Hint = "ﴞ ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- configure html server
-- lspconfig["html"].setup({
--   capabilities = capabilities,
--   on_attach = on_attach,
-- })
--
-- configure typescript server with plugin
-- typescript.setup({
--   server = {
--     capabilities = capabilities,
--     on_attach = on_attach,
--   },
-- })

-- configure css server
-- lspconfig["cssls"].setup({
--   capabilities = capabilities,
--   on_attach = on_attach,
-- })
--
-- configure tailwindcss server
-- lspconfig["tailwindcss"].setup({:
--   capabilities = capabilities,
--   on_attach = on_attach,
-- })

-- configure emmet language server
-- lspconfig["emmet_ls"].setup({
--   capabilities = capabilities,
--   on_attach = on_attach,
--   filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
--})

ccls_server_config = {
  filetypes = { "c", "cpp", "objc", "objcpp", "opencl" },
  root_dir = function(fname)
    return util.root_pattern(".plzconfig", "compile_commands.json", "compile_flags.txt", ".git")(fname)
       or util.find_git_ancestor(fname)
  end,
  on_attach = on_attach,
  capabilities = capabilities,
}

ccls.setup{ lsp = { lspconfig = ccls_server_config } }

lspconfig.gopls.setup{
  cmd = {"gopls", "serve"},
  codelenses = {
    gc_details = true, 
  },
  filetypes = {"go", "gomod"},
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
       analyses = {
         unusedparams = true,
       },
       staticcheck = true,
    },
  },
  on_attach = function(_, bufnr) 
    vim.api.nvim_create_autocmd({ 'BufEnter', 'InsertLeave', 'BufWritePost', 'CursorHold' }, {
       callback = vim.lsp.codelens.refresh,
       group = vim.api.nvim_create_augroup('gopls', { clear = true }), 
       buffer = bufnr, 
       desc = 'Refresh codelenses when gopls is running', 
    })
  end
}

-- 
lspconfig["rust_analyzer"].setup({
  on_attach = on_attach, 
  settings = {
    ["rust-analyzer"] = {
      imports = {
        granularity = { group = "module" }, 
        prefix = "self",
      },
      cargo = {
        buildScripts = { enable = true },
      },
      procMacro = { enable = true },
    },
  }
})

-- configure lua server (with special settings)
lspconfig["lua_ls"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = { -- custom settings for lua
    Lua = {
      -- make the language server recognize "vim" global
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        -- make language server aware of runtime files
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.stdpath("config") .. "/lua"] = true,
        },
      },
    },
  },
})
