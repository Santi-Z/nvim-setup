call plug#begin()
" Themes
Plug 'maxmx03/dracula.nvim'
Plug 'lunacookies/vim-colors-xcode'
Plug 'navarasu/onedark.nvim'
Plug 'marko-cerovac/material.nvim'

" General
Plug 'nvim-lualine/lualine.nvim'
Plug 'Pocco81/auto-save.nvim'
Plug 'm4xshen/autoclose.nvim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'honza/vim-snippets'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'numToStr/Comment.nvim'
Plug 'rcarriga/nvim-notify'
Plug 'nvim-treesitter/nvim-treesitter', {'branch' : 'master', 'do': ':TSUpdate'}
Plug 'neovim/nvim-lspconfig'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'mhinz/vim-signify'
Plug 'anuvyklack/middleclass'
Plug 'anuvyklack/windows.nvim'
Plug 'akinsho/toggleterm.nvim'
Plug 'sindrets/diffview.nvim'

" Dependencies
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug '3rd/image.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'kawre/leetcode.nvim'

" Claude Code
Plug 'coder/claudecode.nvim'

call plug#end()

" Theme Setup
set termguicolors
let g:material_style = "deep ocean"
lua << EOF
require('onedark').setup {
	style = 'darker',
	highlights = {
		["@comment"] = { fg = '#9f9f9f'},
		["@variable"] = {fg = '#bfbfbf'},
	}
}
EOF
colorscheme xcodedarkhc " dracula | xcode | material | onedark

" Claude Code Setup
lua << EOF
require('claudecode').setup()
EOF

" Leetcode setup
nnoremap <leader>r :Leet run<CR>
lua << EOF
require('leetcode').setup({
	lang = "cpp",
	-- lang = "rust",
	storage = {
		home = "/Users/santi/Code/leetcode",
		cache = "/Users/santi/Code/leetcode/nvim-leetcode-cache",
	},
	image_support = true,
	theme = {
		-- ["alt"] = { bg = "#FFFFFF", },
		["normal"] = { fg = "#BFBFBF", },
	},
	injector = {
		["rust"] = {
			before = { "#![allow(dead_code)]", "", "fn main(){}", "struct Solution;" },
		},
	},
	hooks = {
		["question_enter"] = {
			function(question)
				if question.lang ~= "rust" then return end

				local cargo_path = require("leetcode.config").user.storage.home .. "/Cargo.toml"
				local content = [[
				[package]
				name = "leetcode"
				edition = "2024"

				[lib]
				name = "q%s"
				path = "%s"

				[dependencies]
				rand = "0.8"
				regex = "1"
				itertools = "0.14.0"
				]]

				local file = io.open(cargo_path, "w")
				if file then
					file:write((content:gsub("\t+", "")):format(question.q.frontend_id, question:path()))
					file:close()
					vim.fn.system("cd " .. vim.fn.shellescape(require("leetcode.config").user.storage.home) .. " && cargo fetch")
					vim.cmd("CocRestart")
				else
					vim.notify("Failed to write " .. cargo_path, vim.log.levels.ERROR)
				end
			end,
		},
	},
})
EOF

" Lualine setup
lua << EOF
require('lualine').setup()
EOF

" Image.nvim setup
lua << EOF
require('image').setup()
EOF

lua << EOF
require("toggleterm").setup()
EOF

" Telescope setup
nnoremap <leader>t :Telescope find_files<CR>
nnoremap <leader>g :Telescope live_grep<CR>
nnoremap <leader>gf :Telescope grep_string<CR>

" Comment.nvim setup
lua << EOF
require('Comment').setup()
EOF

" Auto Save Setup
lua << EOF
require("auto-save").setup {
opts = {
 -- ... other options
 condition = function(buf)
local fn = vim.fn
local utils = require("auto-save.utils.data")

-- First check the default conditions
if not (fn.getbufvar(buf, "&modifiable") == 1 and utils.not_in(fn.getbufvar(buf, "&filetype"), {})) then
 return false
end

-- Exclude claudecode diff buffers by buffer name patterns
local bufname = vim.api.nvim_buf_get_name(buf)
if bufname:match("%(proposed%)") or
  bufname:match("%(NEW FILE %- proposed%)") or
  bufname:match("%(New%)") then
 return false
end

-- Exclude by buffer variables (claudecode sets these)
if vim.b[buf].claudecode_diff_tab_name or
  vim.b[buf].claudecode_diff_new_win or
  vim.b[buf].claudecode_diff_target_win then
 return false
end

-- Exclude by buffer type (claudecode diff buffers use "acwrite")
local buftype = fn.getbufvar(buf, "&buftype")
if buftype == "acwrite" then
 return false
end

return true -- Safe to auto-save
 end,
},
}
EOF

" Go Setup
autocmd BufRead,BufNewFile *.tmpl,*.gotmpl set filetype=gotmpl
lua << EOF
vim.lsp.enable('gopls')
EOF

" Window Setup
lua << EOF
require('windows').setup()
EOF

" Main Settings
set autoindent smarttab
set noexpandtab
set tabstop=4 shiftwidth=4 softtabstop=4 "Set these to change indent size
set breakindent
set encoding=utf-8
set mousescroll=ver:1,hor:6

" Window Settings
set winwidth=30
set winminwidth=30
nnoremap <leader>m :WindowsMaximize<CR>
nnoremap <leader>e :WindowsEqualize<CR>

" Claude Code Remap
nnoremap <leader>ac :ClaudeCode<CR>
vnoremap <leader>as :ClaudeCodeSend<CR>

" Select all & Copy (from class)
nnoremap <leader>q /class<CR>V/};<CR>y<CR>:noh<CR>

" Nvim-Tree
lua << EOF
require("nvim-tree").setup()
EOF
nnoremap <leader>ff :NvimTreeToggle<CR>
nnoremap <leader>f :NvimTreeOpen<CR>

" Toggleterm
nnoremap <leader>x :ToggleTerm<CR>

" Diff View
nnoremap <leader>d :DiffviewOpen<CR>
nnoremap <leader>dd :DiffviewClose<CR>

" Autoclose
lua << EOF
require("autoclose").setup()
EOF

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
let g:python3_host_prog='/opt/homebrew/Caskroom/miniconda/base/bin/python'

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

" " Go Definition Remaps
" nnoremap gd <cmd>lua vim.lsp.buf.definition()<CR>
" nnoremap gD <cmd>lua vim.lsp.buf.declaration()<CR>
" nnoremap gi <cmd>lua vim.lsp.buf.implementation()<CR>
" nnoremap gr <cmd>lua vim.lsp.buf.references()<CR>
" nnoremap <C-LeftMouse> <cmd>lua vim.lsp.buf.definition()<CR>

" Rust Remaps
autocmd FileType rust nmap <buffer> gd <Plug>(coc-definition)
autocmd FileType rust nmap <buffer> gD <Plug>(coc-declaration)
autocmd FileType rust nmap <buffer> gi <Plug>(coc-implementation)
autocmd FileType rust nmap <buffer> gr <Plug>(coc-references)

" Startup Commands
let g:go_syntax_enable = 0
let g:go_highlight_string_spellcheck = 0
let g:go_def_mapping_enabled = 0

lua << EOF
require('nvim-treesitter.configs').setup({
  highlight = { enable = true },
  ensure_installed = { "go", "lua", "vim", "cpp", "rust" },
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "go", "rust", "cpp" },
  callback = function()
    vim.treesitter.start()
  end,
})
EOF

" autocmd VimEnter * NvimTreeToggle
" autocmd VimEnter * ClaudeCode
