local map = vim.api.nvim_set_keymap
local o = vim.o
local cmd = vim.cmd

cmd("set nolist");
cmd("set ruler");
cmd("set mouse=");
cmd("set t_Co=256");

-- Theme / overrides
cmd("colorscheme vacme");

require("cmp").setup {
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
        luasnip = true
    }
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
                git = true
            }
        }
    }
})

require'nvim-treesitter.configs'.setup({})
require('neogen').setup({})

require('neogit').setup({})

require('todo-comments').setup {};

cmd [[highlight NvimTreeOpenedFolderName guifg=default]]
cmd [[highlight NvimTreeFolderName guifg=default]]

local lspc = require('lspconfig')
lspc.elmls.setup {};
lspc.gopls.setup {};
lspc.hls.setup {};
lspc.lua_ls.setup {settings = {Lua = {diagnostics = {globals = {'vim'}}}}};
lspc.nil_ls.setup {};
lspc.perlpls.setup {};
lspc.solargraph.setup {};
lspc.ts_ls.setup {};
lspc.zls.setup {};
lspc.htmx.setup {};

o.hlsearch = true;

map('n', '<C-n>', ':NvimTreeToggle<CR>', {noremap = true})
map('n', '<C-p>', ':Files<CR>', {noremap = true})
map('n', '<leader>r', ':NvimTreeRefresh<CR>', {noremap = true})
map('n', '<leader>n', ':Neogen<CR>', {noremap = true})
map('n', '<leader>s', ':%s/\\s\\+$//e', {noremap = true})
map('n', '<leader>fm', ':Telescope manix<CR>', {})
map('n', '<leader>mo', ':MindOpenMain<CR>', {})
map('n', '<leader>mp', ':MindOpenProject<CR>', {})
map('n', '<leader>ot', ':ObsidianToday<CR>', {})
map('n', '<leader>tb', ':TagbarToggle<CR>', {})
map('n', '<leader>t', ':TodoQuickFix<CR>', {})
map('n', '<space>gt', ':GoTest<CR>', {})
map('n', '<leader>g', ':GitGutterToggle<CR>', {noremap = true})
map('n', '<leader>2', ':set list!<CR>', {noremap = true})
map('n', '<leader>3', ':set nu!<CR>', {noremap = true})
map('n', '<leader>4', ':set paste!<CR>', {noremap = true})
map('n', '<leader>m', ':Neogit<CR>', {noremap = true})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})

vim.g["vim_markdown_folding_disabled"] = 1
vim.g["elm_setup_keybindings"] = 0

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)
vim.keymap.set({'n', 'v'}, '<space>f', ':Neoformat<CR>')

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        local opts = {buffer = ev.buf}
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    end
})
