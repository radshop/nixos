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
  home.stateVersion = "24.11";
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    librewolf chromium brave
    google-chrome
    vivaldi
    vlc
    libreoffice-fresh
    thunderbird
    pdfarranger pdfsandwich
    gimp-with-plugins
    yt-dlp
    obs-studio
    sioyek
    conda
    bash-completion
    python311Packages.argcomplete
    dbeaver-bin
    git-filter-repo
    unzip gzip rename
    appimage-run
    id3v2
  ];
}
