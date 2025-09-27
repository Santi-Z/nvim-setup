call plug#begin()
	" Themes
	Plug 'maxmx03/dracula.nvim'
	Plug 'arzg/vim-colors-xcode'
	Plug 'navarasu/onedark.nvim'
	Plug 'marko-cerovac/material.nvim'

	" General
	Plug 'nvim-lualine/lualine.nvim'
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
	
	" Leetcode & Dependencies
	Plug 'MunifTanjim/nui.nvim'
	Plug 'nvim-lua/plenary.nvim'
	Plug '3rd/image.nvim'
	Plug 'nvim-telescope/telescope.nvim', {'tag': '0.1.8'}
	Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'}
	Plug 'kawre/leetcode.nvim'
	
	" Jupyter Notebook
	" Plug 'dccsillag/magma-nvim', {'do': ':UpdateRemotePlugins'}
call plug#end()

" Theme Setup
set termguicolors
let g:material_style = "deep ocean"
" lua << EOF
" require('onedark').setup {
" 	style = 'darker',
" 	highlights = {
" 		["@comment"] = { fg = '#9f9f9f' },
" 		["@variable"] = {fg = '#bfbfbf'},
" 	}
" }
" EOF
colorscheme material " dracula | xcode | material | onedark

" Lualine setup
lua << EOF
require('lualine').setup()
EOF

" Leetcode setup
nnoremap <leader>r :Leet run<CR>
lua << EOF
require('leetcode').setup({
	lang = "cpp",
	storage = {
		home = "/Users/santi/Code/leetcode",
		cache = "/Users/santi/Code/leetcode/nvim-leetcode-cache",
	},
	image_support = true,
	theme = {
		-- ["alt"] = { bg = "#FFFFFF", },
		["normal"] = { fg = "#BFBFBF", },
	},
})
EOF

" Image.nvim setup
lua << EOF
require('image').setup()
EOF

" Telescope setup
nnoremap <leader>t :Telescope find_files<CR>

" Vterm setup
let g:vterm_map_toggleterm = '<C-t>'
let g:vterm_map_togglefocus = '<C-]>'

" Comment.nvim setup
lua << EOF
require('Comment').setup()
EOF

" Auto Save Setup
lua << EOF
require("auto-save").setup {}
EOF

" Notification Setup/Test
" lua << EOF
" require("notify")("Welcome :)")
" EOF

" Tree Sitter Setup
lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "vim", "vimdoc", "cpp", "java", "python", 'html' },
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

" Select all & Copy (from class)
nnoremap <leader>q /class<CR>V/};<CR>y<CR>:noh<CR>

" Nvim-Tree
lua << EOF
require("nvim-tree").setup()
EOF
nnoremap <leader>f :NvimTreeToggle<CR>

" Autoclose
lua << EOF
require("autoclose").setup()
EOF

" Jupyter Notebook
" nnoremap <silent><expr> <LocalLeader>r  :MagmaEvaluateOperator<CR>
" nnoremap <silent>       <LocalLeader>rr :MagmaEvaluateLine<CR>
" xnoremap <silent>       <LocalLeader>r  :<C-u>MagmaEvaluateVisual<CR>
" nnoremap <silent>       <LocalLeader>rc :MagmaReevaluateCell<CR>
" nnoremap <silent>       <LocalLeader>rd :MagmaDelete<CR>
" nnoremap <silent>       <LocalLeader>ro :MagmaShowOutput<CR>
" let g:magma_automatically_open_output = v:false

" CoC Rename & Quickfix
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>qf <Plug>(coc-fix-current)

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
