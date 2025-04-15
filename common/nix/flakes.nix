{ config, lib, pkgs, ... }:

{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
    
    # Configure substituters
    settings.substituters = [
      "https://cache.nixos.org"
    ];
    
    # Auto-optimize store to save disk space
    settings.auto-optimise-store = true;
    
  };
}
