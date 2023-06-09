local map = vim.api.nvim_set_keymap
local o = vim.o
local cmd = vim.cmd

cmd("set nolist");
cmd("set ruler");
cmd("set mouse=");
cmd("set t_Co=256");

-- Theme / overrides
cmd("colorscheme vacme");
cmd("hi Normal ctermbg=none ctermfg=none");
cmd("hi SignColumn none");
cmd("hi LineNr none");
cmd("hi Search cterm=none ctermbg=yellow");

require("compe").setup {
	enabled = true,
	autocomplete = true,
	source = {
		path = true,
		buffer = true,
		calc = true,
		nvim_lsp = true,
		nvim_lua = true,
		vsnip = true,
		ultisnips = true,
		luasnip = true,
	},
}

local telescope = require('telescope')
telescope.load_extension('manix')
telescope.load_extension('fzf')

require("nvim-tree").setup({
	renderer = {
		icons = {
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

require("obsidian").setup({
	dir = "~/Brain",
	daily_notes = {
		folder = "Daily",
	},
	completion = {
		nvim_cmp = false,
	}
})

require 'nvim-treesitter.configs'.setup({})
require('neogen').setup({})

cmd [[highlight NvimTreeOpenedFolderName guifg=default]]
cmd [[highlight NvimTreeFolderName guifg=default]]

local lspc = require("lspconfig")
lspc.elmls.setup {};
lspc.gopls.setup {};
lspc.hls.setup {};
lspc.lua_ls.setup {};
lspc.nil_ls.setup {};
lspc.perlpls.setup {};
lspc.solargraph.setup {};
lspc.tsserver.setup {};
lspc.zls.setup {};

o.hlsearch = true;

map('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true })
map('n', '<C-p>', ':Files<CR>', { noremap = true })
map('n', '<leader>r', ':NvimTreeRefresh<CR>', { noremap = true })
map('n', '<leader>n', ':Neogen<CR>', { noremap = true })
map('n', '<leader>s', ':%s/\\s\\+$//e', { noremap = true })
map('n', '<leader>fm', ':Telescope manix<CR>', {})
map('n', '<leader>mo', ':MindOpenMain<CR>', {})
map('n', '<leader>mp', ':MindOpenProject<CR>', {})
map('n', '<leader>ot', ':ObsidianToday<CR>', {})

map('n', '<leader>g', ':GitGutterToggle<CR>', { noremap = true })
map('n', '<leader>2', ':set list!<CR>', { noremap = true })
map('n', '<leader>3', ':set nu!<CR>', { noremap = true })
map('n', '<leader>4', ':set paste!<CR>', { noremap = true })

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

vim.g["vim_markdown_folding_disabled"] = 1
vim.g["elm_setup_keybindings"] = 0

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		local opts = { buffer = ev.buf }
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
		vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
		vim.keymap.set('n', '<space>f', function()
			vim.lsp.buf.format { async = true }
		end, opts)
	end,
})
