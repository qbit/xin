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

require("nvim-tree").setup({
    renderer = {
        icons = {
	    show = false,
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

cmd[[highlight NvimTreeOpenedFolderName guifg=default]]
cmd[[highlight NvimTreeFolderName guifg=default]]

local lspc = require("lspconfig")
lspc.gopls.setup {};
lspc.nil_ls.setup {};

o.hlsearch = true;

map('n', '<C-n>',     ':NvimTreeToggle<CR>',  {noremap = true})
map('n', '<leader>r', ':NvimTreeRefresh<CR>', {noremap = true})
map('n', '<leader>s', ':%s/\\s\\+$//e',       {noremap = true})

map('n', '<leader>1', ':GitGutterToggle<CR>', {noremap = true})
map('n', '<leader>2', ':set list!<CR>',       {noremap = true})
map('n', '<leader>3', ':set nu!<CR>',         {noremap = true})
map('n', '<leader>4', ':set paste!<CR>',      {noremap = true})

