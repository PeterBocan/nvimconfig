local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- autocommand that reloads neovim and installs/updates/removes plugins
-- when file is saved
vim.cmd([[ 
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins-setup.lua source <afile> | PackerSync
  augroup end
]])


return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use 'nvim-lua/plenary.nvim'

  use 'AlexvZyl/nordic.nvim'
  use  { "nvim-tree/nvim-web-devicons" }

  require('nvim-web-devicons').setup {
      default = true,
      strict = true,
  }
  require('nordic').load()

  use { "folke/which-key.nvim" }

  use { 'ThePrimeagen/harpoon', branch = 'harpoon2', requires = { {'nvim-lua/plenary.nvim'} } } -- Prime's Harpoon 
  use "christoomey/vim-tmux-navigator" -- tmux & split window navigation

  use "szw/vim-maximizer" -- maximizes and restores current window

  use "tpope/vim-surround" -- add, delete, change surroundings (it's awesome)
  use "inkarkat/vim-ReplaceWithRegister" -- replace with register contents using motion (gr + motion)

  use "numToStr/Comment.nvim"


  use "nvim-tree/nvim-tree.lua"

  use {  "nvim-lualine/lualine.nvim", requires = { 'nvim-tree/nvim-web-devicons', opt = true } }

  use { "nvim-telescope/telescope-fzf-native.nvim", run = "make" } -- dependency for better sorting performance
  use { "nvim-telescope/telescope.nvim", branch = "0.1.x" } -- fuzzy finder

  use "hrsh7th/nvim-cmp" -- completion plugin
  use "hrsh7th/cmp-buffer" -- source for text in buffer
  use "hrsh7th/cmp-path" -- source for file system paths

  use "L3MON4D3/LuaSnip" -- snippet engine
  use "saadparwaiz1/cmp_luasnip" -- for autocompletion
  use "rafamadriz/friendly-snippets" -- useful snippets

  use "williamboman/mason.nvim" -- in charge of managing lsp servers, linters & formatters
  use "williamboman/mason-lspconfig.nvim" -- bridges gap b/w mason & lspconfig

  use "neovim/nvim-lspconfig" -- easily configure language servers
  use "hrsh7th/cmp-nvim-lsp" -- for autocompletion
  use { "glepnir/lspsaga.nvim", branch = "main" } -- enhanced lsp uis
  use "jose-elias-alvarez/typescript.nvim" -- additional functionality for typescript server (e.g. rename file & update imports)
  use "onsails/lspkind.nvim" -- vs-code like icons for autocompletion

  use "ranjithshegde/ccls.nvim" -- c++ LSP setup 

  use "jose-elias-alvarez/null-ls.nvim" -- configure formatters & linters
  use "jayp0521/mason-null-ls.nvim" -- bridges gap b/w mason & null-ls

  use { "marcuscaisey/please.nvim", requires = { 
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'mfussenegger/nvim-dap',
  } }

  if packer_bootstrap then
    require('packer').sync()
  end
end)


