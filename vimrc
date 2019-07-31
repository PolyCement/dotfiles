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
" and languages vim is bad at highlighting by default
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
" this one's mine,
Plug '~/projects/vim-tweego'
call plug#end()

" set colour scheme
colorscheme base16-atelier-heath

" enable 24-bit colour if supported (otherwise vim will look weird in termite)
if $COLORTERM == 'truecolor'
    set termguicolors
endif
