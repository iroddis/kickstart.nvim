--  [[ NOTE: ]] Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
require('lazy').setup({
  -- Git related plugins
  'junegunn/vim-easy-align', -- Nice alignment
  'jpalardy/vim-slime', -- Send text from buffer to a tmux pane
  'neovim/nvim-lspconfig', -- LSP
  'nvim-mini/mini.nvim', -- Collection of small utilities
  'stevearc/conform.nvim', -- Autoformatting
  'tanvirtin/monokai.nvim', -- Theme
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>hb', function()
          gs.blame_line { full = false }
        end, { desc = 'git blame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>hD', function()
          gs.diffthis '~'
        end, { desc = 'git diff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- optional but recommended
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
  },
  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  -- Marks management
  {
    'chentoast/marks.nvim',
    event = 'VeryLazy',
    opts = {
      builtin_marks = { '<', '>', '{', '}' },
    },
  },
}, {})

vim.lsp.enable 'ruff_lsp'
vim.lsp.enable 'go'
vim.lsp.enable 'clangd'
vim.lsp.enable 'elixirls'

-- [[ Setting options ]]
vim.opt.ai = true -- Autoindent
vim.opt.updatetime = 50
vim.opt.mouse = ''
vim.opt.ttimeoutlen = 1000
vim.opt.ttimeout = true
-- vim.opt.ttimeoutlen = 0 -- Leader timeout (default 50)

-- Whitespace
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Search
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.smartcase = true

-- Display
vim.opt.nu = true
vim.opt.wrap = false
vim.opt.termguicolors = false
vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.foldlevel = 99
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.wildmode = 'longest:full'

-- swap
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv 'HOME' .. '/tmp/vim.undo'
vim.opt.undofile = true

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

vim.keymap.set('n', '<leader>,', ':w!<CR>')
vim.keymap.set('n', 'qq', ':qa!<CR>')
vim.keymap.set('n', "<leader>'", vim.cmd.tabn)
vim.keymap.set('n', '<leader>;', vim.cmd.tabp)
vim.keymap.set('n', '<C-e>', ':tabe ')
vim.keymap.set('n', '<C-j>', vim.diagnostic.goto_next)
vim.keymap.set('n', '<C-k>', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<leader>r', ':%s/\\s*$//<CR>')

-- Moving code!!
-- vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
-- vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")
-- vim.keymap.set('x', '<leader>o', '"_dP')

-- System copy/paste
vim.keymap.set('n', '<leader>y', '"+y')
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>y', '"+Y')
vim.keymap.set('n', '<leader>Y', ':.w! ~/.vimpaste<CR>')
vim.keymap.set('v', '<leader>Y', ':w! ~/.vimpaste<CR>')
vim.keymap.set('n', '<leader>P', ':r ~/.vimpaste<CR>')

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown' },
  callback = function(_)
    vim.keymap.set('n', '<leader>f', '{!}fmt -p 150<CR>')
    vim.keymap.set('v', '<leader>f', ':!fmt -p 150<CR>')
  end,
})

require('monokai').setup { palette = require('monokai').ristretto }

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

require('mini.icons').setup {}
require('mini.completion').setup {}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Formatting
require('conform').setup {
  formatters_by_ft = {
    elixir = { 'mix' },
    heex = { 'mix' },
    go = { 'gofmt' },
    javascript = { 'prettier' },
    lua = { 'stylua' },
    python = { 'black' },
    rust = { 'rustfmt', lsp_format = 'fallback' },
    cpp = { 'clang-format' },
  },
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_format = 'fallback',
  },
}

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end
vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', function()
    vim.lsp.buf.code_action { context = { only = { 'quickfix', 'refactor', 'source' } } }
  end, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

vim.g.slime_target = 'tmux'

vim.keymap.set('n', '<Space>', '<Plug>SlimeLineSend<CR>')
vim.keymap.set('v', '<Space>', "<Plug>SlimeRegionSend<CR>'>")
vim.keymap.set('n', '<leader>v', ':SlimeConfig<CR><CR>')

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    vim.g.slime_python_ipython = 1
  end,
})

vim.keymap.set('n', 'ga', ':EasyAlign<CR>')
vim.keymap.set('v', 'ga', ':EasyAlign<CR>')

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
  builtin.grep_string { search = vim.fn.input 'Grep > ' }
end)

-- Define a function to highlight the current search term
local highlight_search_term = function(label)
  local search_term = vim.fn.getreg '/'
  if search_term ~= '' then
    -- local matches =
    vim.fn.matchadd(label, search_term)
    -- for match_id in matches do
    --   vim.api.nvim_buf_add_highlight(0, -1, label, 0, match_id[1] - 1, match_id[2])
    -- end
  end
end

vim.keymap.set('n', '<leader>m1', function()
  highlight_search_term 'Matchadd_1'
end)
vim.keymap.set('n', '<leader>m2', function()
  highlight_search_term 'Matchadd_2'
end)
vim.keymap.set('n', '<leader>m3', function()
  highlight_search_term 'Matchadd_3'
end)
vim.keymap.set('n', '<leader>m4', function()
  highlight_search_term 'Matchadd_4'
end)
vim.keymap.set('n', '<leader>m5', function()
  highlight_search_term 'Matchadd_5'
end)
vim.keymap.set('n', '<leader>mc', function()
  vim.fn.clearmatches()
end)

local colors = {
  base03 = '#002b36',
  base02 = '#073642',
  base01 = '#586e75',
  base00 = '#657b83',
  base0 = '#839496',
  base1 = '#93a1a1',
  base2 = '#eee8d5',
  base3 = '#fdf6e3',
  yellow = '#b58900',
  orange = '#cb4b16',
  red = '#dc322f',
  magenta = '#d33682',
  violet = '#6c71c4',
  blue = '#268bd2',
  cyan = '#2aa198',
  green = '#859900',
}

vim.api.nvim_set_hl(0, 'Matchadd_1', { bg = colors.blue, fg = 0 })
vim.api.nvim_set_hl(0, 'Matchadd_2', { bg = colors.violet, fg = 0 })
vim.api.nvim_set_hl(0, 'Matchadd_3', { bg = colors.cyan, fg = 0 })
vim.api.nvim_set_hl(0, 'Matchadd_4', { bg = colors.red, fg = 0 })
vim.api.nvim_set_hl(0, 'Matchadd_5', { bg = colors.orange, fg = 0 })
vim.api.nvim_set_hl(0, 'Matchadd_6', { bg = colors.yellow, fg = 0 })

-- Automatically format
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

-- Because nvim filetypes are stupid ... need to disable formatoptions for all file types
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function()
    vim.opt.formatoptions:remove 'r'
    vim.opt.formatoptions:remove 'o'
  end,
})

-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*",
--   callback = function(args)
--     require("conform").format({ bufnr = args.buf })
--   end,
-- })
-- local augroup = vim.api.nvim_create_augroup
-- local autocmd = vim.api.nvim_create_autocmd
-- augroup("__formatter__", { clear = true })
-- autocmd("BufWritePost", {
--   group = "__formatter__",
--   command = ":FormatWrite",
-- })

-- Disable change-detection if in diff mode. Allows for diffs involving redirects
-- eg nvim -d <(cmd 1) <(cmd 2)
if vim.diff then
  vim.opt.autoread = false
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
