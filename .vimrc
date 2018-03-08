runtime! debian.vim

filetype off
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif
set omnifunc=syntaxcomplete#Complete

call pathogen#helptags()
call pathogen#infect()

syntax on
filetype plugin indent on

let mapleader=","
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>
set hidden
set tabstop=2
set nowrap
set backspace=indent,eol,start
set smartindent
set cindent
set expandtab
set autoindent
set formatoptions+=t
set textwidth=79
set tw=79
set noswapfile
set number
set copyindent
set shiftwidth=2
set softtabstop=2
set shiftround
set showmatch
set ignorecase
set smartcase
set smarttab
set scrolloff=4
set hlsearch
set incsearch
set history=1000
set undolevels=1000
set switchbuf=useopen
set wildmenu
set wildmode=list:full
set wildignore=*.swp,*.bak,*.pyc,*.class
set title
set visualbell
set showcmd
set cursorline
set noerrorbells
set nobackup
set shortmess+=I
set clipboard=unnamedplus
set autoread
nnoremap <C-e> 2<C-e>
nnoremap <C-y> 2<C-y>

" Folding rules {{{
set foldenable                  " enable folding
set foldcolumn=2                " add a fold column
set foldmethod=syntax           " detect triple-{ style fold markers
set foldlevelstart=99           " start out with everything unfolded
let javascript_fold=1         " JavaScript
let g:clojure_folds="defn,def,ns,let,macro,defprotocol,defrecord,s/defrecord,extend-type,s/defn,s/def,[,{,("
let clojure_fold=1
let ruby_fold=1               " Ruby
set foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo
                                " which commands trigger auto-unfold
function! MyFoldText()
    let line = getline(v:foldstart)

    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let foldedlinecount = v:foldend - v:foldstart

    " expand tabs into spaces
    let onetab = strpart('          ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')

    let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount) - 4
    return line . ' …' . repeat(" ",fillcharcount) . foldedlinecount . ' '
endfunction
set foldtext=MyFoldText()

if executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>
  let g:ctrlp_use_caching = 0
endif

" Mappings to easily toggle fold levels
nnoremap z0 :set foldlevel=0<cr>
nnoremap z1 :set foldlevel=1<cr>
nnoremap z2 :set foldlevel=2<cr>
nnoremap z3 :set foldlevel=3<cr>
nnoremap z4 :set foldlevel=4<cr>
nnoremap z5 :set foldlevel=5<cr>
inoremap qf <C-O>za
nnoremap ;f za
onoremap ;f <C-C>za
vnoremap ;f zf
" }}}

" tab navigation like firefox {{{
nnoremap th  :tabfirst<CR>
nnoremap tj  :tabnext<CR>
nnoremap tk  :tabprev<CR>
nnoremap tl  :tablast<CR>
nnoremap tt  :tabedit<Space>
nnoremap tn  :tabnext<Space>
nnoremap tm  :tabm<Space>
nnoremap td  :tabclose<CR>
" }}}


" tmux config {{{
let g:tmux_navigator_no_mappings = 1
let g:tmux_navigator_save_on_switch = 0

map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

nnoremap <silent> <C-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <C-j> :TmuxNavigateDown<cr>
nnoremap <silent> <C-k> :TmuxNavigateUp<cr>
nnoremap <silent> <C-l> :TmuxNavigateRight<cr>
nnoremap <silent> <C-p> :TmuxNavigatePrevious<cr>
" }}}

" Toggle the foldcolumn {{{
nnoremap <leader>f :call FoldColumnToggle()<cr>



let g:last_fold_column_width = 4

function! FoldColumnToggle()
    if &foldcolumn
        let g:last_fold_column_width = &foldcolumn
        setlocal foldcolumn=0
      syntax on
    else
        let &l:foldcolumn = g:last_fold_column_width
    endif
endfunction
" }}}
"

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

" Highlighting {{{
if &t_Co > 2 || has("gui_running")
   syntax on                    " switch syntax highlighting on, when the terminal has colors
au BufNewFile,BufRead *.cljc set filetype=clojure
au BufNewFile,BufRead *.clj set filetype=clojure
au BufNewFile,BufRead *.boot set filetype=clojure
au BufNewFile,BufRead *.cljx set filetype=clojure
au BufNewFile,BufRead *.cljs set filetype=clojure
au BufNewFile,BufRead *.less set filetype=css
endif
" }}}

" Allow quick additions to the spelling dict
nnoremap <leader>g :spellgood <c-r><c-w>

let g:clojure_syntax_keywords = {
    \ 'clojureMacro': ["defproject", "defcustom"],
    \ 'clojureFunc': ["string/join", "string/replace"]
    \ }
let g:clojure_fuzzy_indent = 1
let g:clojure_fuzzy_indent_blacklist = ['-fn$', '\v^with-%(meta|out-str|loading-context)$']
let g:clojure_special_indent_words = 'deftype,defrecord,reify,proxy,extend-type,extend-protocol,letfn'
let g:clojure_fuzzy_indent_patterns = 'with.*,def.*,let.*'
let g:clojure_align_multiline_strings = 1
let g:clojure_align_subforms = 1
"let vimclojure#HighlightBuiltins=1
"let vimclojure#FuzzyIndent=1
"let vimclojure#HighlightContrib=1
"let vimclojure#DynamicHighlighting=1
function! Config_Rainbow()
    call rainbow_parentheses#load(0)
    call rainbow_parentheses#load(1)
    call rainbow_parentheses#load(2)
endfunction

function! Load_Rainbow()
    call rainbow_parentheses#activate()
endfunction

augroup TastetheRainbow
    autocmd!
    autocmd Syntax * call Config_Rainbow()
    autocmd VimEnter,BufRead,BufWinEnter,BufNewFile * call Load_Rainbow()
augroup END


function! DeleteFile(...)
  if(exists('a:1'))
    let theFile=a:1
  elseif ( &ft == 'help' )
    echohl Error
    echo "Cannot delete a help buffer!"
    echohl None
    return -1
  else
    let theFile=expand('%:p')
  endif
  let delStatus=delete(theFile)
  if(delStatus == 0)
    echo "Deleted " . theFile
  else
    echohl WarningMsg
    echo "Failed to delete " . theFile
    echohl None
  endif
  return delStatus
endfunction

"delete the current file
com! Rm call DeleteFile()
"delete the file and quit the buffer (quits vim if this was the last file)
com! RM call DeleteFile() <Bar> q!

function! CopyOutput()
redir @">
 silent execute Last!
redir END
endfunction

com! CL call CopyOutput()

" NERDTree settings {{{
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <leader>m :NERDTreeClose<CR>:NERDTreeFind<CR>
nnoremap <leader>N :NERDTreeClose<CR>
map <C-n> :NERDTreeToggle<CR>

let NERDTreeBookmarksFile=expand("$HOME/.vim/NERDTreeBookmarks")
let NERDTreeShowBookmarks=1
let NERDTreeShowFiles=1
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=1
let NERDTreeHighlightCursorline=1
let NERDTreeMouseMode=2
let NERDTreeIgnore=[ '\.pyc$', '\.pyo$', '\.py\$class$', '\.obj$',
            \ '\.o$', '\.so$', '\.egg$', '^\.git$' ]

" }}}
"
command! -range Vis call setpos('.', [0,<line1>,0,0]) |
                    \ exe "normal V" |
                    \ call setpos('.', [0,<line2>,0,0])

" Editor layout {{{
set termencoding=utf-8
set encoding=utf-8
set lazyredraw                  " don't update the display while executing macros
set laststatus=2                " tell VIM to always put a status line in, even
                                "    if there is only one window
set cmdheight=2                 " use a status bar that is 2 rows high
" }}}
"
"
function! RedirResult(msgcmd)
    redir! > tmp.out
    silent execute a:msgcmd
    redir END
    :let @+=system("tail -n +4 tmp.out")
    :silent :exe 'norm i' . system("rm tmp.out")
endfunction

nnoremap <silent> cps :call RedirResult("Eval")<CR>
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.
set pastetoggle=<F2>
nnoremap ; :
vmap Q gp
nmap Q gqap
map <silent> ,/ :nohlsearch<CR>
cmap w!! w !sudo tee % >/dev/null
