"indentation settings
set expandtab
set shiftwidth=4
set softtabstop=4
set autoindent

"improve line wrapping behaviour
set breakindent
set linebreak

"syntax highlighting
syntax on

"search highlighting
set hlsearch

"plugins!
call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'dietsche/vim-lastplace'
call plug#end()
