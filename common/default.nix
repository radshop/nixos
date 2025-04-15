{ config, lib, pkgs, ... }:

{
  imports = [
    # Import any other common modules you have
    # For example, if you created the flakes support file:
    ./nix/flakes.nix
    ./nix/github-token.nix
  ];

  # Any other common configurations go here
}
