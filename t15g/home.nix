{ config, pkgs, ... }:

{
  # disable temporarily
  # imports = [ ./dconf.nix ];
  home.username = "miscguy";
  home.homeDirectory = "/home/miscguy";
  home.stateVersion = "23.05";
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    firefox librewolf brave chromium
    logseq
    vlc
    libreoffice-fresh
  ];

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      function conda-shell {
          nix-shell ~/nixos/conda/conda-shell.nix
      }
    '';
    # profileExtra = ''
    #   docker start sql1
    # '';
  };

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
        vim-obsession
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
      if has("autocmd")
        au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
      endif
    '';
  };

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-capture-pane-contents 'on'
          resurrect_dir="$HOME/.tmux/resurrect"
          set -g @resurrect-dir $resurrect_dir
          set -g @resurrect-hook-post-save-all 'target=$(readlink -f $resurrect_dir/last); sed "s| --cmd .*-vim-pack-dir||g; s|/etc/profiles/per-user/$USER/bin/||g" $target | sponge $target'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
          '';
      }
    ];
    extraConfig = ''
      bind-key r source-file ~/.config/tmux/tmux.conf \; display-message "~/.tmux.conf reloaded."
    '';
  };
}
