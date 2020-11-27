set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

Plugin 'scrooloose/nerdtree'
Plugin 'valloric/youcompleteme'
Plugin 'xolox/vim-easytags'
Plugin 'majutsushi/tagbar'
Plugin 'tpope/vim-fugitive'
Plugin 'easymotion/vim-easymotion'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'scrooloose/nerdcommenter'
Plugin 'matze/vim-move'
Plugin 'raimondi/delimitmate'
Plugin 'mattn/emmet-vim'
Plugin 'scrooloose/syntastic'
Plugin 'tpope/vim-surround'
Plugin 'sirver/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'xolox/vim-session'
Plugin 'xolox/vim-misc'
Plugin 'SyntaxAttr.vim'
Plugin 'dyng/ctrlsf.vim'
Plugin 'rking/ag.vim'
Plugin 'godlygeek/tabular'

Plugin 'stanangeloff/php.vim'
Plugin 'sumpygump/php-documentor-vim'
Plugin 'arnaud-lb/vim-php-namespace'

Plugin 'pangloss/vim-javascript'

Plugin 'othree/html5.vim'

Plugin 'evidens/vim-twig'

Plugin 'mtscout6/vim-tagbar-css'

Plugin 'damage220/solas.vim'
Plugin 'nanotech/jellybeans.vim'
Plugin 'mhartington/oceanic-next'

call vundle#end()

set tabstop=4
set shiftwidth=4
set softtabstop=4

set autoread

set autoindent
set smartindent

set encoding=utf-8
set termencoding=utf-8

set splitright

set cursorline

set nocp
set nu
set laststatus=2
set ruler
set nowrap
syntax enable
set background=dark
colorscheme solas

set visualbell t_vb=
set novisualbell

let g:session_autosave = 'no'

set fileformat=unix
set statusline=%f%m%r%h%w\ %y\ enc:%{&enc}\ ff:%{&ff}\ fenc:%{&fenc}%=(ch:%3b\ hex:%2B)\ col:%2c\ line:%2l/%L\ [%2p%%]