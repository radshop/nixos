{ config, pkgs, ... }:

{
  home.username = "miscguy";
  home.homeDirectory = "/home/miscguy";
  home.stateVersion = "23.05";
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    firefox librewolf brave chromium
  ];

  programs.git = {
    enable = true;
    userName = "radshop";
    userEmail = "myron@radshop.com";
  };

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; 
      [ vim-commentary
        vim-fugitive
        vimoutliner
        vim-surround
      ];
    settings = { ignorecase = true; };
    extraConfig = ''
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
  };

  programs.tmux = {
    enable = true;
    plugins = with pkgs;
    [ tmuxPlugins.sensible
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
          '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-boot 'on'
          '';
      }
    ];
  };
}
