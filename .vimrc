" plug
call plug#begin()
Plug 'rust-lang/rust.vim'
Plug 'scrooloose/nerdtree'
Plug 'w0rp/ale'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

" history
set history=700

" Vim recommended
if has('autocmd')
  filetype plugin indent on
endif
if has('syntax') && !exists('g:syntax_on')
  syntax enable
endif
set synmaxcol=9999
set hidden " Allows you to switch buffers without saving current
set wildmenu "tab completion
set wildmode=longest:full,full " First tab brings up options, second tab cycles
set encoding=utf8
set clipboard=unnamedplus
set nobackup
set noswapfile
set noundofile

" Movement
let mapleader = ","
set tm=2000
noremap ,, ,

" treat wrapped lines as different lines
nnoremap j gj
nnoremap k gk

" Enable mouse support
set mouse=a

" Set 7 lines to the cursor - when moving vertically using j/k
set so=7

" Always show current position
set ruler

" Remove bell
set visualbell
set t_vb=

" Better searching
set incsearch
set ignorecase
set smartcase
set wrapscan "wraps around end of file
" Redraw screen and clear highlighting
nnoremap <Leader>r :nohl<CR><C-L>

" Don't redraw while executing macros (good performance config)
set lazyredraw

" tabs
set expandtab
set smarttab

" nowrap
set nowrap

" Show matching bracket
set showmatch
set matchtime=2
set shiftwidth=2
set tabstop=2
set number
set wildmenu
set wildmode=list:full
set wildignore=*.swp,*.bak,*.pyc,*.class
set title
set visualbell
set noerrorbells
set nobackup
let g:autofmt_autosave = 1

"fuzy file search
set path+=**

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Return to last edit position when opening files (You want this!)
augroup last_edit
  autocmd!
  autocmd BufReadPost *
       \ if line("'\"") > 0 && line("'\"") <= line("$") |
       \   exe "normal! g`\"" |
       \ endif
augroup END

" Close nerdtree after a file is selected
let NERDTreeQuitOnOpen = 1

function! IsNERDTreeOpen()
  return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction

function! ToggleFindNerd()
  if IsNERDTreeOpen()
    exec ':NERDTreeToggle'
  else
    exec ':NERDTreeFind'
  endif
endfunction

" CtrlP using ripgrep
if executable('rg')
  set grepprg=rg\ --color=never
  let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
  let g:ctrlp_use_caching = 0
endif

" If nerd tree is closed, find current file, if open, close it
nmap <silent> <leader>f <ESC>:call ToggleFindNerd()<CR>
nmap <silent> <leader>F <ESC>:NERDTreeToggle<CR>

set statusline=%f\ %h%w%m%r\ %=%(%l,%c%V\ %=\ %P%)

" Ale syntax checking
let g:ale_rust_cargo_use_check = 1
" use Ctrl-k and Ctrl-j to jump up and down between errors
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

"ale config
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)
let g:ale_echo_msg_format = '%s'

" Tabbing function
" (Based on http://stackoverflow.com/questions/5927952/whats-implementation-of-vims-default-tabline-function)
if exists("+showtabline")
    function! MyTabLine()
        let s = ''
        let wn = ''
        let t = tabpagenr()
        let i = 1
        while i <= tabpagenr('$')
            let buflist = tabpagebuflist(i)
            let winnr = tabpagewinnr(i)
            let s .= '%' . i . 'T'
            let s .= (i == t ? '%1*' : '%2*')
            let s .= ' '
            let wn = tabpagewinnr(i,'$')

            let s .= '%#TabNum#'
            let s .= i
            " let s .= '%*'
            let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
            let bufnr = buflist[winnr - 1]
            let file = bufname(bufnr)
            let buftype = getbufvar(bufnr, 'buftype')
            if buftype == 'nofile'
                if file =~ '\/.'
                    let file = substitute(file, '.*\/\ze.', '', '')
                endif
            else
                let file = fnamemodify(file, ':p:t')
            endif
            if file == ''
                let file = '[No Name]'
            endif
            let s .= ' ' . file . ' '
            let i = i + 1
        endwhile
        let s .= '%T%#TabLineFill#%='
        let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
        return s
    endfunction
    set stal=2
    set tabline=%!MyTabLine()
    set showtabline=1
    highlight link TabNum Special
endif

nnoremap 1 :tabn 1<Return>
nnoremap 2 :tabn 2<Return>
nnoremap 3 :tabn 3<Return>
nnoremap 4 :tabn 4<Return>
nnoremap 5 :tabn 5<Return>
nnoremap 6 :tabn 6<Return>
nnoremap 7 :tabn 7<Return>
nnoremap 8 :tabn 8<Return>
nnoremap 9 :tabn 9<Return>
nnoremap > :20winc ><Return>
nnoremap < :20winc <<Return>
nnoremap _ :20winc -<Return>
nnoremap + :20winc +<Return>
" Add line without entering insert
nmap <S-Enter> O<Esc>
nmap <CR> o<Esc>
