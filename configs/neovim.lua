local map = vim.api.nvim_set_keymap
local o = vim.o
local cmd = vim.cmd

cmd("syntax off");
cmd("set t_Co=0");
cmd("hi LineNr NONE");
cmd("set nolist");
cmd("set ruler");
cmd("set mouse-=n");

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

require("nvim-tree").setup()

local lspc = require("lspconfig")
lspc.gopls.setup {};

o.hlsearch = true;

map('n', '<C-n>',     ':NvimTreeToggle<CR>',  {noremap = true})
map('n', '<leader>r', ':NvimTreeRefresh<CR>', {noremap = true})
map('n', '<leader>s', ':%s/\\s\\+$//e',       {noremap = true})

map('n', '<leader>1', ':GitGutterToggle<CR>', {noremap = true})
map('n', '<leader>2', ':set list!<CR>',       {noremap = true})
map('n', '<leader>3', ':set nu!<CR>',         {noremap = true})
map('n', '<leader>4', ':set paste!<CR>',      {noremap = true})

