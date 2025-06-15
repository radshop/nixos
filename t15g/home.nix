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
  home.stateVersion = "25.05";
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    firefox librewolf brave chromium
    #logseq
    vlc
    libreoffice-fresh
  ];


}
