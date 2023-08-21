{ config, pkgs, ... }:

{
  home.username = "miscguy";
  home.homeDirectory = "/home/miscguy";
  home.stateVersion = "22.11";
  home.packages = with pkgs; [
    firefox librewolf brave chromium
  ];
}
