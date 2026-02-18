{ config, pkgs, ... }:

{
  imports = [ 
    ../shared/vim.nix  
    ../shared/tmux.nix  
    ../shared/git.nix  
    ../shared/bash.nix  
    ../shared/firefox.nix
  ];
  home.username = "miscguy";
  home.homeDirectory = "/home/miscguy";
  home.stateVersion = "25.05";
  #nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    librewolf chromium brave
    google-chrome
    vivaldi
    vlc
    libreoffice-fresh
    thunderbird
    pdfarranger pdfsandwich
    yt-dlp
    sioyek
    conda
    bash-completion
    python311Packages.argcomplete
    dbeaver-bin
    git-filter-repo
    unzip gzip rename
    appimage-run
    kitty
    sqlite
    python312Packages.gunicorn python312Packages.flask
    qgis
    anki
    simple-scan
    transmission_4-gtk
  ];
}
