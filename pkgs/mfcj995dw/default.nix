{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

{
  mfcj995dwlpr = pkgs.callPackage ./mfcj995dwlpr.nix {};
  mfcj995dwcupswrapper = pkgs.callPackage ./mfcj995dwcupswrapper.nix {};
  brscan4 = pkgs.callPackage ./brscan4.nix {};
}
