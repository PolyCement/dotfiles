" ========== nvim settings ==========

" most of this stuff is ported over from my old vim config, sans a bunch of
" stuff that is already set by default in nvim :)

" ========== built-in settings ==========

" indentation settings
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

" improve line wrapping behaviour
set breakindent
set linebreak

" show line numbers
set number
set relativenumber

" highlight the current line number (but not the whole line)
set cursorline
set cursorlineopt=number

" enable mouse
set mouse=a

" ========== binds and rebinds ==========

" bind esc to ctrl + \, ctrl + n (allows exiting terminal mode by hitting esc)
" afaik this will only apply in terminal mode - either way, its what the docs
" suggested so hopefully it won't cause issues?
tnoremap <Esc> <C-\><C-n>

" ========== custom commands ==========

" open a terminal in a new vertical window
command -nargs=* STerm split | terminal <args>
command -nargs=* VTerm vsplit | terminal <args>
" short versions of the above
command -nargs=* ST STerm <args>
command -nargs=* VT VTerm <args>

" ========== autocmds ==========

" disable line numbers in terminal buffers
au TermOpen * setlocal nonumber norelativenumber

" ========== plugins ==========

call plug#begin()
    " general good stuff
    Plug 'tpope/vim-sleuth'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-repeat'
    Plug 'farmergreg/vim-lastplace'
    Plug 'jeffkreeftmeijer/vim-numbertoggle'
    Plug 'ap/vim-buftabline'
    " base16 colourschemes
    Plug 'chriskempson/base16-vim'
    " syntax highlighting
    Plug 'elixir-editors/vim-elixir'
    Plug 'yuezk/vim-js'
    Plug 'HerringtonDarkholme/yats.vim'
    Plug 'MaxMEllon/vim-jsx-pretty'
call plug#end()

" ========== plugin settings ==========

" buftabline:
" enable numbering for buftabline
let g:buftabline_numbers=1

" base16-vim:
" set colour scheme
colorscheme base16-atelier-heath
" stop theme making the background opaque
highlight Normal guibg=NONE
" enable 24-bit colour if supported (otherwise vim will look weird in termite/alacritty)
if $COLORTERM == 'truecolor'
    set termguicolors
endif

" vim-elixir:
" temporary workaround for broken .heex highlighting
" see: https://github.com/elixir-editors/vim-elixir/issues/562
au BufRead,BufNewFile *.ex,*.exs set filetype=elixir
au BufRead,BufNewFile *.eex,*.heex,*.leex,*.sface,*.lexs set filetype=eelixir
au BufRead,BufNewFile mix.lock set filetype=elixir
