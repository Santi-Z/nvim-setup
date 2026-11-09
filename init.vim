call plug#begin()
" General
Plug 'lunacookies/vim-colors-xcode'
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
Plug 'lervag/vimtex'
Plug 'coder/claudecode.nvim'
Plug 'echasnovski/mini.starter'

" Dependencies
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug '3rd/image.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'kawre/leetcode.nvim'
Plug 'folke/snacks.nvim'

" Jupyter Notebook
Plug 'benlubas/molten-nvim', {'do': ':UpdateRemotePlugins'}
Plug 'GCBallesteros/jupytext.nvim'
call plug#end()

" Theme Setup
set termguicolors
set guifont=Iosevka:h13
" Force black background for xcodedarkhc
augroup BlackBackground
	autocmd!
	autocmd ColorScheme xcodedarkhc highlight Normal guibg=#000000 ctermbg=0
				\ | highlight NormalNC guibg=#000000 ctermbg=0
				\ | highlight NormalFloat guibg=#000000 ctermbg=0
				\ | highlight SignColumn guibg=#000000 ctermbg=0
				\ | highlight EndOfBuffer guibg=#000000 ctermbg=0
augroup END
" Docstrings use the same color as comments (all languages, all colorschemes)
augroup DocstringAsComment
	autocmd!
	autocmd ColorScheme * highlight! link @string.documentation Comment
augroup END
" Startup screen: blue/teal from colorscheme instead of orange (WarningMsg)
augroup StarterColors
	autocmd!
	autocmd ColorScheme * highlight! link MiniStarterItemPrefix Directory
				\ | highlight! link MiniStarterQuery Special
augroup END
colorscheme xcodedarkhc " xcode

" Claude Code Setup
lua << EOF
require('claudecode').setup({
	terminal = { provider = "snacks" },
})

-- Claude Code's fullscreen UI keeps its history internally (nvim scrollback stays empty),
-- so in normal mode forward scroll and arrow keys to Claude. Claude terminals only:
-- buffer name is term://{cwd}//{pid}:{cmd}, match when the command's executable is `claude`.
-- Each key briefly enters terminal mode, presses the key there (so nvim encodes it the way
-- Claude expects), then returns to normal mode.
local function claude_term_maps(buf)
	local cmd = vim.api.nvim_buf_get_name(buf):match("//%d+:(.*)$") or ""
	local exe = cmd:match("^(%S+)") or ""
	if vim.bo[buf].buftype ~= "terminal" or not exe:match("claude$") then return end
	local keys = {
		['<C-u>'] = '<PageUp>',   -- half screen up
		['<C-d>'] = '<PageDown>', -- half screen down
		['gg'] = '<C-Home>',      -- top of conversation
		['G'] = '<C-End>',        -- bottom, resume auto-follow
		['h'] = '<Left>',         -- session -> agents view
		['j'] = '<Down>',
		['k'] = '<Up>',
		['l'] = '<Right>',
	}
	for lhs, key in pairs(keys) do
		vim.keymap.set('n', lhs, 'i' .. key .. [[<C-\><C-n>]], { buffer = buf, silent = true })
	end
	-- <C-u>/<C-d>: keep cursor in the same screen position (line + column) after the
	-- terminal-mode round trip, which otherwise moves it.
	for lhs, key in pairs({ ['<C-u>'] = '<PageUp>', ['<C-d>'] = '<PageDown>' }) do
		vim.keymap.set('n', lhs, function()
			_G._claude_restore_pos = vim.fn.getcurpos()
			local seq = vim.api.nvim_replace_termcodes(
				'i' .. key .. [[<C-\><C-n>]] .. '<Cmd>lua vim.fn.setpos(".", _G._claude_restore_pos)<CR>',
				true, false, true)
			vim.api.nvim_feedkeys(seq, 'n', false)
		end, { buffer = buf, silent = true })
	end
	-- <C-x> in normal mode is vim's decrement (E21 on a terminal buffer). Send it to Claude
	-- and stay in terminal mode so the rest of the chord (ctrl+x ctrl+x, ctrl+x ctrl+k, ...) reaches Claude.
	vim.keymap.set('n', '<C-x>', 'i<C-x>', { buffer = buf, silent = true })
	-- Arrow keys disabled while typing in Claude too (practise hjkl from normal mode;
	-- the non-recursive maps above still send real arrows)
	for _, key in ipairs({ '<Up>', '<Down>', '<Left>', '<Right>' }) do
		vim.keymap.set('t', key, '<Nop>', { buffer = buf })
	end
end
vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("ClaudeTermMaps", { clear = true }),
	callback = function(ev) claude_term_maps(ev.buf) end,
})
-- Also cover Claude terminals already open when this file is (re)sourced
for _, buf in ipairs(vim.api.nvim_list_bufs()) do claude_term_maps(buf) end

-- Snacks forces winfixwidth on vertical split terminals, which makes windows.nvim treat them as fixed
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
	callback = function()
		vim.schedule(function()
			if vim.bo.filetype == "snacks_terminal" then
				vim.wo.winfixwidth = false
			end
		end)
	end,
})
EOF

" Leetcode setup
nnoremap <leader>r :Leet run<CR>
lua << EOF
require('leetcode').setup({
	-- lang = "cpp",
	lang = "rust",
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

" Intro screen (mini.starter)
lua << EOF
local starter = require('mini.starter')
starter.setup({
	header = table.concat({
		"███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
		"████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
		"██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
		"██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
		"██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
		"╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
	}, "\n"),
	items = {
		starter.sections.recent_files(5, true),  -- current dir only
		starter.sections.recent_files(5, false), -- anywhere
		starter.sections.builtin_actions(),
		{ name = "Find file",   action = "Telescope find_files", section = "Actions" },
		{ name = "Grep",        action = "Telescope live_grep",  section = "Actions" },
		{ name = "Leetcode",    action = "Leet",                 section = "Actions" },
		{ name = "Plug update", action = "PlugUpdate",           section = "Actions" },
	},
	content_hooks = {
		starter.gen_hook.adding_bullet(),
		starter.gen_hook.aligning('center', 'center'),
	},
	footer = "",
})
EOF

" Image.nvim setup
lua << EOF
require('image').setup()
EOF

lua << EOF
require("toggleterm").setup()
EOF

" VimTeX setup
let g:vimtex_view_method = 'skim'
let g:vimtex_view_skim_sync = 1     " Forward search after each successful compile
let g:vimtex_view_skim_activate = 0 " Keep focus in nvim when Skim updates

" Telescope setup
nnoremap <leader>t :Telescope find_files<CR>
nnoremap <leader>g :Telescope live_grep<CR>
nnoremap <leader>w :Telescope grep_string<CR>

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

" Window Setup
lua << EOF
require('windows').setup()
EOF

" Disable arrow keys to practise hjkl (normal, visual, operator-pending, insert)
for key in ['<Up>', '<Down>', '<Left>', '<Right>']
	execute 'noremap' key '<Nop>'
	execute 'inoremap' key '<Nop>'
endfor

" Main Settings
lua << EOF
vim.opt.showmode = false
vim.opt.cmdheight = 0
EOF
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
" Split windows (overrides visual-block <C-v> and decrement <C-x> in normal mode)
nnoremap <C-v> :vsp<CR>
nnoremap <C-x> :sp<CR>
nnoremap <C-a> $
vnoremap <C-a> $
onoremap <C-a> $
nnoremap <C-i> ^
vnoremap <C-i> ^
onoremap <C-i> ^
" Window navigation with <C-h/j/k/l> from normal and terminal mode, landing in normal mode
" Jumplist: <C-o> back (default), <C-p> forward
nnoremap <C-p> <C-i>
" (stopinsert is scheduled so it runs after a terminal's auto_insert; <C-l> overrides the
" Neovim default nohlsearch/redraw, use :noh instead)
lua << EOF
for _, dir in ipairs({ 'h', 'j', 'k', 'l' }) do
	vim.keymap.set({ 'n', 't' }, '<C-' .. dir .. '>', function()
		vim.cmd.wincmd(dir)
		vim.schedule(function() vim.cmd.stopinsert() end)
	end, { silent = true, desc = "Window " .. dir .. ", stay in normal mode" })
end
EOF

" Claude Code Remap
nnoremap <leader>ac :ClaudeCode<CR>
vnoremap <leader>as :ClaudeCodeSend<CR>

" Nvim-Tree
lua << EOF
require("nvim-tree").setup()
EOF
nnoremap <leader>f :NvimTreeToggle<CR>

" Toggleterm
nnoremap <leader>x :ToggleTerm<CR>

" Diff View
nnoremap <silent> <leader>d <cmd>lua if require('diffview.lib').get_current_view() then vim.cmd('DiffviewClose') else vim.cmd('DiffviewOpen') end<CR>

" Autoclose
lua << EOF
require("autoclose").setup({
  keys = {
    ["("] = { escape = false, close = false, pair = "()" },
    ["["] = { escape = false, close = false, pair = "[]" },
    ["<"] = { escape = false, close = false, pair = "<>" },
    [")"] = { escape = false, close = false, pair = "()" },
    ["]"] = { escape = false, close = false, pair = "[]" },
    [">"] = { escape = false, close = false, pair = "<>" },
    ['"'] = { escape = false, close = false, pair = '""' },
    ["'"] = { escape = false, close = false, pair = "''" },
    ["`"] = { escape = false, close = false, pair = "``" },
  },
})
EOF

" Jupyter Notebook
let maplocalleader = ","
let g:molten_image_provider = "image.nvim"
let g:molten_auto_open_output = v:false
let g:molten_output_win_max_height = 20
nnoremap <silent> <LocalLeader>mi :MoltenInit<CR>
nnoremap <silent> <LocalLeader>e  :MoltenEvaluateOperator<CR>
nnoremap <silent> <LocalLeader>rl :MoltenEvaluateLine<CR>
nnoremap <silent> <LocalLeader>rr :MoltenReevaluateCell<CR>
xnoremap <silent> <LocalLeader>r  :<C-u>MoltenEvaluateVisual<CR>gv
nnoremap <silent> <LocalLeader>rd :MoltenDelete<CR>
nnoremap <silent> <LocalLeader>oh :MoltenHideOutput<CR>
nnoremap <silent> <LocalLeader>os :noautocmd MoltenEnterOutput<CR>
lua << EOF
require("jupytext").setup()

-- Run the "# %%" cell under the cursor (molten has no notion of jupytext cells)
local function run_cell(advance)
	local cur = vim.fn.line(".")
	local last = vim.fn.line("$")
	local start = vim.fn.search("^# %%", "bcnW")
	start = (start == 0) and 1 or start + 1
	local stop = vim.fn.search("^# %%", "nW")
	stop = (stop == 0) and last or stop - 1
	if stop >= start then
		vim.fn.MoltenEvaluateRange(start, stop)
	end
	if advance and stop < last then
		vim.api.nvim_win_set_cursor(0, { math.min(stop + 2, last), 0 })
	end
end
vim.keymap.set("n", "<LocalLeader>rc", function() run_cell(false) end, { silent = true, desc = "Molten run cell" })
vim.keymap.set("n", "<LocalLeader>rn", function() run_cell(true) end, { silent = true, desc = "Molten run cell and go to next" })
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
set updatetime=800

" Leave insert mode with jj
inoremap jj <Esc>

" Clear search highlight with <Esc>
nnoremap <silent> <Esc> :noh<CR>

" Scrolling
set scrolloff=4
" <C-u>/<C-d>/<C-f>/<C-b>/G etc: keep cursor column instead of jumping to first non-blank
set nostartofline

" Python Setting
let g:python3_host_prog='/opt/homebrew/Caskroom/miniconda/base/bin/python'

" Autocompletion settings
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
set pumheight=15

" " Go Definition Remaps
" nnoremap gd <cmd>lua vim.lsp.buf.definition()<CR>
" nnoremap gD <cmd>lua vim.lsp.buf.declaration()<CR>
" nnoremap gi <cmd>lua vim.lsp.buf.implementation()<CR>
" nnoremap gr <cmd>lua vim.lsp.buf.references()<CR>
" nnoremap <C-LeftMouse> <cmd>lua vim.lsp.buf.definition()<CR>

" Coc Go-to Remaps (all languages)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gD <Plug>(coc-declaration)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gy <Plug>(coc-type-definition)

" Hover docs: K manual, auto after cursor idle in normal mode (delay = updatetime)
nnoremap <silent> K :call CocActionAsync('doHover')<CR>

function! s:AutoHover() abort
  if mode() ==# 'n' && !coc#float#has_float() && CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  endif
endfunction
autocmd CursorHold * silent! call s:AutoHover()

" Scroll coc float (hover/docs) with <C-f>/<C-b>. While any float is open, never fall
" through to page scroll (it moves the buffer and the hovered word leaves the screen).
function! s:FloatKey(fwd, key) abort
  if coc#float#has_scroll()
    return coc#float#scroll(a:fwd)
  endif
  return coc#float#has_float() ? "" : a:key
endfunction
nnoremap <silent><nowait><expr> <C-f> <SID>FloatKey(1, "\<C-f>")
nnoremap <silent><nowait><expr> <C-b> <SID>FloatKey(0, "\<C-b>")
" Same in insert mode, for completion doc windows
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(1)\<CR>" : "\<C-f>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(0)\<CR>" : "\<C-b>"


" Startup Commands
let g:go_syntax_enable = 0
let g:go_highlight_string_spellcheck = 0
let g:go_def_mapping_enabled = 0

lua << EOF
require('nvim-treesitter.configs').setup({
  highlight = { enable = true },
  ensure_installed = { "go", "lua", "vim", "cpp", "rust", "python" },
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
