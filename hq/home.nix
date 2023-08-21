{ config, pkgs, ... }:

{
  home.username = "miscguy";
  home.homeDirectory = "/home/miscguy";
  home.stateVersion = "23.11";
  home.packages = with pkgs; [
    firefox librewolf brave chromium
  ];
}
