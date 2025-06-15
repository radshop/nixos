{ config, lib, pkgs, ... }:

{
  nixpkgs.config.displaylink = {
    enable = true;
  };
  
  # Make local drivers available to Nix
  nixpkgs.config.packageOverrides = pkgs: {
    displaylink = pkgs.displaylink.override {
      inherit (config.boot.kernelPackages) evdi;
    };
  };
}