with import <nixpkgs> {};

vim_configurable.customize {
  name = "vim";
  vimrcConfig.customRC = ''
    set nocompatible
    filetype off
    syntax on
    set autoindent
    set smarttab
    set tabstop=2
    set softtabstop=2
    set shiftwidth=2
    set expandtab
    set number relativenumber
    set ruler
    set more
    set showcmd ruler
    set laststatus=2
    set title
    nnoremap \\ :noh<return> "clear search highlighting with \\
    set background=dark
    colorscheme elflord
    set directory=$HOME/.temp//
    let mapleader = "\\"
    set timeoutlen=3000
    set backspace=indent,eol,start " fully enbled backspace
  '';
}
