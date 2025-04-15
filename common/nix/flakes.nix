{ config, lib, pkgs, ... }:

{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
    
    # Optional but recommended: configure substituters for faster builds
    settings.substituters = [
      "https://cache.nixos.org"
    ];
    
    # Auto-optimize store to save disk space
    settings.auto-optimise-store = true;

    # extraOptions = '' access-tokens = github.com=${builtins.readFile home/miscguy/nixos/secrets/github_token} '';
  };
}
