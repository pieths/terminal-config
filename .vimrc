set nocompatible
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin

set nohlsearch
set number
set autoindent
set nowrap
set path=.,./**
set ts=4
set expandtab
set sw=4
set hidden
set aw
set makeprg=make
set vb
if has('win32') || has('win64')
    set nofixendofline
endif

set foldcolumn=2
set foldtext=substitute(getline(v:foldstart),'/\\*\\\|\\*/\\\|{{{\\d\\=','','g')

if has("gui_running")
    set guioptions-=T
    set guioptions-=m
    set lines=65
    set columns=130

    if has('win32') || has('win64')
        set guifont=Consolas:h10:cANSI:qDRAFT
    endif

    " Custom gui options for diff mode
    if &diff
        set columns=180
    endif
endif

" Stores the ~ files in the HOME/.vimbackup directory
" if it exists. Otherwise puts them in the current
" directory.
" The backupdir= is for the ~ files.
" The directory= is for the swap files
if has('win32') || has('win64')
    set backupdir=%USERPROFILE%/.vimbackup
    set directory=%USERPROFILE%/.vimbackup
else
    set backupdir=~/.vimbackup,.
    set directory=~/.vimbackup,.
endif

" Number of lines to scroll with <c-U> and <c-D>
set scroll=6

" Remove indentation when '{' is not at the front of the line.
" Used for 'namespace FOO {' lines so that rest does not indent.
set cino+=e-4

" File/Directory patterns to ignore when using ZOP (see wildignore)
set wildignore+=.svn,.hg,*.o,moc_*,tst_*

" Stop the *.un~ files from being created.
set noundofile

let g:netrw_liststyle=3

" Enable syntax highlighting in markdown
" fenced blocks for the following languages.
let g:markdown_minlines = 75
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'javascript', 'json', 'cs']

" Add the dash character to keywords to help
" with things like css completion
set iskeyword+=\-

" Turn off searching in include files and tags.
" This was causing slow downs when trying to
" use ctrl-p autocomplete with python files
set complete-=i
set complete-=t

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let mapleader = "Z"

map j		gj
map k		gk
map <Leader><space>   :ls<cr>:b 
map <Leader><S-space> :ls<cr>:b 

map <c-h> ^
map <c-l> $
map <c-j> <c-d>
map <c-k> <c-u>
map <c-m> :w<cr>
map <c-p> :bp<cr>
map <c-n> :bn<cr>

" Extra window movement mappings
map <Leader>J		<c-w>j
map <Leader>K		<c-w>k
map <Leader>H		<c-w>h
map <Leader>L		<c-w>l

" Swap the ` and ' keys in normal mode
" so that jumping to marks will jump to the
" actual specified location in the line
nnoremap ` '
nnoremap ' `

" Close buffer without closing the window
map <Leader>bd :Bclose<cr>

" This resets the <c-m> mapping to carriage return so
" that quickfix enter events will open the file under
" the cursor as they should.
autocmd BufReadPost quickfix nnoremap <buffer> <c-m> <CR>

" WORD grep. Grep for the word under the cursor
" recursively in the current directory
nnoremap <Leader>* :call WordGrep()<CR>
vnoremap <Leader>* :call VisualGrep()<CR>

" Visual mode pressing * or # searches for the current selection
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>

" Revert <c-a> back to number increment. This is
" set to 'select-all' when mswin.vim is sourced
nnoremap <c-a> <c-a>

" C++ style commenting
map <Leader>lco	:s/^/\/\//<cr>
map <Leader>rco	:s/^\/\///<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Highlighting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Force specific colors regardless of colorscheme
autocmd ColorScheme *
    \ highlight Normal guibg=#000000 ctermbg=black |
    \ highlight Normal guifg=#DDDDDD ctermfg=white |
    \ highlight Comment guifg=#666666 ctermbg=black ctermfg=DarkGrey |
    \ highlight LineNr guifg=#666666 ctermbg=black ctermfg=DarkGrey |
    \ highlight PreProc guifg=#999999 ctermbg=black ctermfg=DarkGrey |
    \ highlight FoldColumn guibg=#000000 guifg=#DDDDDD ctermbg=black |
    \ highlight Statement gui=NONE |
    \ highlight Todo guifg=#000000 guibg=#a0a000 |
    \ highlight Number guifg=LightMagenta ctermfg=LightMagenta |
    \ highlight String ctermfg=217 guifg=#ffa0a0 |
    \ highlight Identifier term=underline cterm=bold ctermfg=14 guifg=#40ffff |
    \ highlight Statement term=bold ctermfg=227 guifg=#ffff60 |
    \ highlight Special term=bold ctermfg=214 guifg=Orange |
    \ highlight Directory term=bold ctermfg=14 guifg=Cyan |
    \ highlight Visual term=reverse ctermbg=8 guibg=#808080 |
    \ highlight Search term=reverse ctermfg=0 ctermbg=11 guifg=Black guibg=Yellow |
    \ highlight Type term=underline ctermfg=83 guifg=#60ff60 |
    \ highlight CursorLine term=reverse ctermbg=8 guibg=#808080

" Note: the colors in the terminal preferences dialog may
" change the indexed colors in the active color palette.
" See https://jonasjacek.github.io/colors/ for 256 values

colo default

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Dynamic loading of the python environment
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"set pythonthreedll=C:\Users\v-pischo\AppData\Local\Programs\Python\Python37-64\python37.dll
"set pythonthreehome=C:\Users\v-pischo\AppData\Local\Programs\Python\Python37-64\

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! CmdLine(str)
    call feedkeys(":" . a:str)
endfunction 

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'gv'
        call CmdLine("Ack '" . l:pattern . "' " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

function! WordGrep()
    execute 'grep! -rIn --exclude-dir="\.git" --exclude-dir="\.svn"  --exclude-dir="*/tst_*" --exclude="*moc_*" --exclude="*project.pbxproj*" ' . expand('<cword>') . ' .'
    cw
endfunction

function! VisualGrep() range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", "\"")
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    let @/ = l:pattern
    let @" = l:saved_reg

    let l:commandString = 'grep! -rInF --exclude-dir="\.git" --exclude-dir="\.svn" "' . @/ . '" .'
    execute l:commandString
    cw
endfunction

command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = bufnr("#")

    if buflisted(l:alternateBufNum)
        buffer #
    else
        bnext
    endif

    if bufnr("%") == l:currentBufNum
        new
    endif

    if buflisted(l:currentBufNum)
        execute("bdelete! ".l:currentBufNum)
    endif
endfunction

