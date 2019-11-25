set nocompatible
" source $VIMRUNTIME/vimrc_example.vim
" source $VIMRUNTIME/mswin.vim
" behave mswin

set viminfo+=!

"Set mapleader
let mapleader = ","
let g:mapleader = ","

"Fast reloading of the .vimrc
map <leader>s :source $VIM/_vimrc<cr>
"Fast editing of .vimrc
map <leader>a :e! $VIM/_vimrc<cr>


" colorscheme torte
" colorscheme mycolor
set directory=/tmp/vim
set path=.
set number
set autoindent
set tabstop=4
set shiftwidth=4
set nobackup
set clipboard=unnamed
set hidden
set smartcase
set smartindent
set nowrapscan
set iminsert=0
set imsearch=0
set laststatus=2
set cmdheight=2

set ruler
set showcmd
set list
set listchars=tab:+-,extends:>,trail:-,eol:~
set hlsearch
set lz
set backspace=eol,start,indent
set magic

"No sound on errors.
set noerrorbells
set novisualbell

syntax on
filetype plugin indent on

" ファイルの違いによる変化

" 検索系
" 大文字、小文字区別せず
set ignorecase

" 行番号表示、サブディレクトリも表示
set grepprg=grep\ -rnH

" 行番号表示、サブディレクトリも表示、正規表現検索
"set grepprg=findstr\ /n\ /S\ /R


" gvimの場合のみウインドウサイズ変更
if has("gui_win32")
	set cursorline
	hi cursorline guibg=#333333
	"hi CursorColumn guibg=#333333
	set guifont=ＭＳ_ゴシック:h10:cSHIFTJIS
	set co=108
	set lines=35
endif


" keymap変更 --------------------------
map J <C-d>
map K <C-u>
"nmap J 10j
"nmap K 10k

nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

nmap <leader>7 <C-w><
nmap <leader>8 <C-w>>
nmap <leader>9 <C-w>+
nmap <leader>0 <C-w>-

nmap n nzz
nmap N Nzz

nmap <right> :bn<cr>
nmap <left> :bp<cr>
nmap <up> :tabp<cr>
nmap <down> :tabn<cr>

map <leader>gg :set tags=$TAGS/
map <leader>gl :!dir c:\ito\local\tags<cr>
" map <leader>gg :cs add $TAGS/
" map <leader>gd :cs add $TAGS/ c:\disco\6000\
" map <leader>gl :!dir c:\ito\local\tags<cr>

"windowの最大化
map <leader>x :simalt ~x<cr>
"windowを戻す
map <leader>r :simalt ~r<cr>
"windowの移動
map <leader>m :simalt ~m<cr>
"windowの最小化
" map <leader>n :simalt ~n<cr>

" tab,buffer操作系
nmap <F10> :tabp<cr>
nmap <F11> :tabn<cr>
nmap <F12> :bwipe<cr>
nmap <leader>c :tabp<cr>
nmap <leader>v :tabn<cr>
nmap <leader>w :bp<cr>
nmap <leader>e :bn<cr>
nmap <leader>q :bwipe!<cr>
"nmap <leader>n :cn<cr>
"nmap <leader>p :cp<cr>
nmap <leader>o :only<cr>

nnoremap <C-q> <C-w>

if has("autocmd")
	filetype plugin indent on

	autocmd BufNewFile,BufRead *.js set filetype=javascript
	autocmd BufNewFile,BufRead *.jsx set filetype=javascript
	autocmd BufNewFile,BufRead *.html set filetype=html

	autocmd FileType javascript		setlocal sw=2 sts=2 ts=2 et
	autocmd FileType js				setlocal sw=2 sts=2 ts=2 et
	autocmd FileType html			setlocal sw=2 sts=2 ts=2 et
	autocmd FileType css			setlocal sw=2 sts=2 ts=2 et
	autocmd FileType scss			setlocal sw=2 sts=2 ts=2 et
	autocmd FileType sass			setlocal sw=2 sts=2 ts=2 et
	autocmd FileType json			setlocal sw=2 sts=2 ts=2 et

	"入力モード時、ステータスラインのカラーを変更
	autocmd InsertEnter * highlight StatusLine guifg=#ccdc90 guibg=#2E4340
	autocmd InsertLeave * highlight StatusLine guifg=#2E4340 guibg=#ccdc90
	autocmd BufNewFile,BufRead * highlight StatusLine guifg=#2E4340 guibg=#ccdc90
endif


" ステータスライン
set statusline=%n:\ %<%f\ %m%r%h%w[%{&fileformat}][%{has('multi_byte')&&\ &fileencoding!=''?&fileencoding:&encoding}]\ 0x%B=%b%=%l,%c\ %P


"モード切替時、日本語入力をリセット
au InsertEnter * set iminsert=0 imsearch=0
au InsertLeave * set iminsert=0 imsearch=0

"全角スペースを視覚化
" highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=#666666
" au BufNewFile,BufRead * match ZenkakuSpace /　/
" highlight OrgComment guifg=darkgreen
" au BufNewFile,BufRead * match OrgComment /^[\t ]*[;!].*[\n\r]/
" au BufNewFile,BufRead * match OrgComment /^[\t ]*[#][\t ].*[\n\r]/

"日本語入力をリセット
au BufNewFile,BufRead * set iminsert=0 imsearch=0
"タブ幅をリセット
"au BufNewFile,BufRead * set tabstop=4 shiftwidth=4


" Project.vim用 ---------------------------------
let g:proj_window_width = 30		"windowの横幅
" map <leader>p :Project<cr>


" taglist ---------------------------------------
"ctagsのパス
" let Tlist_Ctags_Cmd = "/usr/bin/ctags"

"現在編集中のソースのタグしか表示しない
let Tlist_Show_One_File = 1

"taglistのウィンドーが最後のウィンドーならばVimを閉じる
let Tlist_Exit_OnlyWindow = 1

"右側でtaglistのウィンドーを表示
" let Tlist_Use_Right_Window = 1

map <leader>t :TlistToggle<cr>
map <leader>n :call Navi()<cr>


" yankring -------------------------------------
nmap <leader>y :YRShow<cr>


" cscope ---------------------------------------
if has("cscope")
	"set cscopequickfix=s+,g+,c+,d+,i+,t+,e+
	set cscopequickfix=s-,g-,c-,d-,i-,t-,e-
endif

" ctags.vim ------------------------------------
" let g:ctags_regenerate = 0
" let g:ctags_statusline = 1
" let g:ctags_title = 1

" neobundle ------------------------------------
" if has('vi_starting')
set runtimepath^=~/.vim/bundle/neobundle.vim/
" endif

call neobundle#begin(expand('~/.vim/bundle/'))

NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundleLazy 'heavenshell/vim-jsdoc' , {'autoload': {'filetypes': ['javascript']}}
NeoBundle 'moll/vim-node'

NeoBundle 'pangloss/vim-javascript'

NeoBundle 'Townk/vim-autoclose'

NeoBundle 'thinca/vim-quickrun'
let g:quickrun_config={'*': {'split': ''}}

call neobundle#end()

NeoBundleCheck

filetype plugin indent on
