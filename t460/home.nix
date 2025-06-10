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
  home.packages = with pkgs; [
    librewolf brave chromium
    google-chrome 
    libreoffice-fresh
    yt-dlp
    remmina
    claude-code
  ];

}
