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
  home.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    librewolf chromium 
    # google-chrome vivaldi
    teams-for-linux
    brave
    logseq
    vlc
    libreoffice-fresh
    thunderbird
    pdfarranger pdfsandwich
    gimp-with-plugins
    element-desktop
    yt-dlp
    obs-studio
    ranger
    bc # command line calculator
    freeplane
    squirrel-sql
    dia
  ];
}
