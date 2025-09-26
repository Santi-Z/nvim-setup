call plug#begin()
	Plug 'maxmx03/dracula.nvim'
	Plug 'arzg/vim-colors-xcode'
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'
	Plug 'Pocco81/auto-save.nvim'
	Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
	Plug 'm4xshen/autoclose.nvim'
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	Plug 'SirVer/ultisnips'
	Plug 'honza/vim-snippets'
	Plug 'nvim-tree/nvim-tree.lua'
	Plug 'nvim-tree/nvim-web-devicons'
	Plug 'keitokuch/vterm'
	Plug 'numToStr/Comment.nvim'
	Plug 'rcarriga/nvim-notify'
	Plug 'MunifTanjim/nui.nvim'

	Plug 'nvim-lua/plenary.nvim'
	Plug 'nvim-telescope/telescope.nvim', {'tag': '0.1.8'}
	Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'}
	Plug 'dccsillag/magma-nvim', {'do': ':UpdateRemotePlugins'}
call plug#end()

" Theme Setup
set termguicolors
colorscheme dracula

" Comment.nvim setup
lua << EOF
	require('Comment').setup()
EOF

" Auto Save Setup
lua << EOF
	require("auto-save").setup {}
EOF

" Notification Setup/Test
lua << EOF
	require("notify")("Welcome :)")
EOF

" Tree Sitter Setup
lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "vim", "vimdoc", "cpp", "java", "python" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
EOF

" Main Settings
set autoindent smarttab
set noexpandtab
set tabstop=4 shiftwidth=4 softtabstop=4 "Set these to change indent size
set breakindent
set encoding=utf-8

" Nvim-Tree
lua << EOF
	require("nvim-tree").setup()
EOF

" Autoclose
lua << EOF
	require("autoclose").setup()
EOF

" Jupyter Notebook
nnoremap <silent><expr> <LocalLeader>r  :MagmaEvaluateOperator<CR>
nnoremap <silent>       <LocalLeader>rr :MagmaEvaluateLine<CR>
xnoremap <silent>       <LocalLeader>r  :<C-u>MagmaEvaluateVisual<CR>
nnoremap <silent>       <LocalLeader>rc :MagmaReevaluateCell<CR>
nnoremap <silent>       <LocalLeader>rd :MagmaDelete<CR>
nnoremap <silent>       <LocalLeader>ro :MagmaShowOutput<CR>

let g:magma_automatically_open_output = v:false

" CoC Rename & Quickfix
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>qf <Plug>(coc-fix-current)

" .java - java program
" CS 1332 requires spaces
autocmd FileType java setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4

" Search settings
set ignorecase smartcase

" Line Numbers
set number relativenumber
command NumberToggle :setlocal relativenumber!

" Clipboard
set clipboard+=unnamedplus

" Backup files thing?
set nobackup nowritebackup

" Scrolling
set scrolloff=4
set scroll=1

" Vim-Airline
let g:airline_theme='deus'
let g:airline_powerline_fonts = 1

" Python Setting
let g:python3_host_prog='/usr/bin/python3'

" Autocompletion settings
" Ultisnips Specific
let g:UltiSnipsExpandTrigger="<F12>"
" Coc Specific
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'
