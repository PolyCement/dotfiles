" indentation settings
set expandtab
set shiftwidth=4
set softtabstop=4
set autoindent

" improve line wrapping behaviour
set breakindent
set linebreak

" syntax highlighting
syntax on

" search highlighting
set hlsearch

" set hidden so i dont have to save buffers to switch between em
set hidden

" if this aint set numbertoggle does nothing
set number relativenumber

" highlight the current line number (but not the whole line)
set cursorline
set cursorlineopt=number

" plugins!
call plug#begin()
" general good stuff
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
" i suspect this might be causing issues when opening to a specified line
" number - check how unity is calling vim cos i can't reproduce the bug myself
Plug 'dietsche/vim-lastplace'
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'ap/vim-buftabline'
" base16 colourschemes
"Plug 'chriskempson/base16-vim'
" dude ain't maintaining his repo rn and his plugin broke so here's a fixed fork
Plug 'danielwe/base16-vim'
" syntax highlighting for other languages
Plug 'tikhomirov/vim-glsl', { 'for': 'glsl' }
Plug 'calviken/vim-gdscript3'
Plug 'elmcast/elm-vim'
Plug 'digitaltoad/vim-pug'
" and languages vim is bad at highlighting by default
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
" this probably has to be loaded after the js one? not sure if order matters
Plug 'mxw/vim-jsx'
" i guess i use typescript now...
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
" this one's mine,
Plug '~/projects/vim-tweego'
call plug#end()

" set colour scheme
colorscheme base16-atelier-heath

" for whatever reason cursorlinenr just had no setting applied til recently?
" and it suddenly started applying underline, which looks bad to me, so...
" huh this seems to be related to this actually: https://github.com/vim/vim/issues/5017
" maybe give this another look next time vim updates but tbh i like it bold
highlight CursorLineNr cterm=bold

" enable 24-bit colour if supported (otherwise vim will look weird in termite)
if $COLORTERM == 'truecolor'
    set termguicolors
endif

" enable numbering for buftabline
let g:buftabline_numbers=1
