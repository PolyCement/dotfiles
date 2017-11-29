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

" plugins!
call plug#begin()
" general good stuff
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'dietsche/vim-lastplace'
Plug 'jeffkreeftmeijer/vim-numbertoggle'
" base16 colourschemes
Plug 'chriskempson/base16-vim'
" syntax highlighting for other languages
Plug 'tikhomirov/vim-glsl', { 'for': 'glsl' }
" this one's mine,
Plug '~/projects/vim-tweego'
call plug#end()

" set colour scheme
colorscheme base16-atelier-heath
