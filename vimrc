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
Plug 'chriskempson/base16-vim'
" syntax highlighting for other languages
Plug 'tikhomirov/vim-glsl', { 'for': 'glsl' }
Plug 'calviken/vim-gdscript3'
Plug 'elmcast/elm-vim'
Plug 'digitaltoad/vim-pug'
Plug 'elixir-editors/vim-elixir'
" and languages vim is bad at highlighting by default
Plug 'yuezk/vim-js'
" i guess i use typescript now...
Plug 'leafgarland/typescript-vim'
" this probably has to be loaded after the js one? not sure if order matters
" also it covers typescript jsx too which is nice
Plug 'maxmellon/vim-jsx-pretty'
" adjust tab size automatically
" (i'm a softtabstop=4 girl living in a softtabstop=2 world)
Plug 'tpope/vim-sleuth'
" this one's mine,
Plug '~/projects/vim-tweego'
call plug#end()

" set colour scheme
colorscheme base16-atelier-heath

" make the line number of the current line bold instead of underlined
highlight CursorLineNr cterm=bold
" make visual mode invert colours rather than using a dark grey that makes the text borderline unreadable
" note that bg is set over fg due to reverse flipping the colours
highlight Visual cterm=reverse guibg=#1b181b
" similar for matching parenthesis highlighting
highlight MatchParen cterm=reverse guibg=#1b181b
" stop theme making the background opaque
highlight Normal guibg=NONE

" enable 24-bit colour if supported (otherwise vim will look weird in termite/alacritty)
if $COLORTERM == 'truecolor'
    set termguicolors
endif
" fixes colours being fucked in alacritty, 
execute "set t_8f=\e[38;2;%lu;%lu;%lum"
execute "set t_8b=\e[48;2;%lu;%lu;%lum"

" enable numbering for buftabline
let g:buftabline_numbers=1

" enable mouse
set mouse=a
set ttymouse=sgr

" chokidar a shit
au FileType javascript,typescript setl backupcopy=yes
