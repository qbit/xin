local map = vim.api.nvim_set_keymap
local o = vim.o
local cmd = vim.cmd

--cmd("syntax off");
--cmd("set t_Co=0");
cmd("set nolist");
cmd("set ruler");
cmd("set mouse=");
cmd("set t_Co=256");
cmd("colorscheme vacme");
cmd("hi! Normal ctermbg=NONE ctermfg=NONE");
cmd("hi! Normal ctermbg=NONE ctermfg=NONE");
cmd("hi! Normal ctermbg=NONE ctermfg=NONE");
cmd("hi! SignColumn NONE");
cmd("hi! LineNr NONE");
cmd("hi! Search cterm=NONE ctermbg=yellow");

require("compe").setup {
	enabled = true;
	autocomplete = true;
	source = {
		path = true;
		buffer = true;
		calc = true;
		nvim_lsp = true;
		nvim_lua = true;
		vsnip = true;
		ultisnips = true;
		luasnip = true;
	};
}

local telescope = require('telescope')
telescope.load_extension('manix')
telescope.load_extension('fzf')

require("nvim-tree").setup({
	renderer = {
		icons = {
			--show = false,
			webdev_colors = false,
			show = {
				file = false,
				folder = false,
				folder_arrow = false,
				git = true,
			},
		},
	},
})

require('mind').setup()
require("obsidian").setup({
  dir = "~/Brain",
  daily_notes = {
    folder = "Daily",
  },
  completion = {
    nvim_cmp = false,
  }
})

cmd [[highlight NvimTreeOpenedFolderName guifg=default]]
cmd [[highlight NvimTreeFolderName guifg=default]]

local lspc = require("lspconfig")
lspc.gopls.setup {};
lspc.nil_ls.setup {};
lspc.sumneko_lua.setup {};
lspc.solargraph.setup {};

o.hlsearch = true;

map('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true })
map('n', '<C-p>', ':Files<CR>', { noremap = true })
map('n', '<leader>r', ':NvimTreeRefresh<CR>', { noremap = true })
map('n', '<leader>s', ':%s/\\s\\+$//e', { noremap = true })
map('n', '<leader>fm', ':Telescope manix<CR>', {})
map('n', '<leader>mo', ':MindOpenMain<CR>', {})
map('n', '<leader>mp', ':MindOpenProject<CR>', {})
map('n', '<leader>ot', ':ObsidianToday<CR>', {})

map('n', '<leader>1', ':GitGutterToggle<CR>', { noremap = true })
map('n', '<leader>2', ':set list!<CR>', { noremap = true })
map('n', '<leader>3', ':set nu!<CR>', { noremap = true })
map('n', '<leader>4', ':set paste!<CR>', { noremap = true })
vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
