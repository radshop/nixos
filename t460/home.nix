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
    librewolf brave chromium
    google-chrome 
    libreoffice-fresh
    yt-dlp
  ];

}
