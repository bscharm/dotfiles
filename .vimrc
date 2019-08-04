" --------------
" VIM Config
" --------------

set number
set nocompatible              " be iMproved, required
syntax on
filetype plugin indent on
filetype off                  " required

" --------------
" Vundle
" --------------

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.

Plugin 'junegunn/fzf.vim'
Plugin 'itchyny/lightline.vim'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'tpope/vim-surround'
Plugin 'scrooloose/nerdtree'
Plugin 'fatih/vim-go'

call vundle#end()            " required

" --------------
" fzf Config
" --------------
map ; :Files<CR>

" ---------------
" NERDTree Config
" ---------------
 map <C-o> :NERDTreeToggle<CR>

" ---------------
" Go Config
" ---------------
let g:go_fmt_command = "goimports"
