{
  description = "Radshop's NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Add Home Manager as a flake input
    home-manager = {
      url = "github:nix-community/home-manager";
      # This makes home-manager use the same nixpkgs as your system
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      nixhq = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hq/configuration.nix
          ./common
          
          # Add Home Manager's NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.miscguy = import ./hq/home.nix;
          }
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}
