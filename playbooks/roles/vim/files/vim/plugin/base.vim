filetype on
filetype plugin on
filetype indent on
compiler ruby

set history=1000
set cf
set ffs=unix,dos,mac

"Theme/Colors
set background=dark
syntax on
colorscheme torte

"Files/Backups
set backup
set backupdir=~/.vim/backup
set directory=~/.vim/temp

"Visual cues
set ruler
set relativenumber
set colorcolumn=81
set scrolloff=2

"Highlight whitespace at the end of a line
highlight WhitespaceEOL ctermbg=blue guibg=blue
match WhitespaceEOL /\s\+$/

" Text formatting/layout
set autoindent
set smartindent
set cindent
set tabstop=2
set softtabstop=2
set shiftwidth=2
set noexpandtab
set nowrap
set smarttab

"Folding
set foldenable "turn it on
set foldmethod=indent "folding should be wary of indents
set foldlevel=100 "don't fold anything (but let me fold manually)
