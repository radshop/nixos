{
  description = "Radshop's NixOS configurations";

  inputs = {
    # Use stable or unstable channel as your preferred base
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # You can add other inputs as needed
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      # Define your nixhq system
      nixhq = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";  # Adjust if using a different architecture
        modules = [
          # Include your common configurations
          ./common
          # Include your hq-specific configurations
          ./hq
          
          # This module sets any flake-specific items
          ({ ... }: {
            # Set the NIX_PATH and other flake-specific configurations
            nix.registry.nixpkgs.flake = nixpkgs;
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
          })
        ];
        # Pass inputs to modules that might need them
        specialArgs = { inherit inputs; };
      };
      
      # You can add other systems following the same pattern
    };
  };
}
