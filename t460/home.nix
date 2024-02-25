# sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager

{ config, pkgs, ... }:

{
  imports = [ 
    ../shared/vim.nix  
    ../shared/tmux.nix  
    ../shared/git.nix  
    ../shared/bash.nix  
  ];
  home.username = "miscguy";
  home.homeDirectory = "/home/miscguy";
  home.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    firefox librewolf brave chromium
    logseq
    vlc
    libreoffice-fresh
    yt-dlp
  ];

}
