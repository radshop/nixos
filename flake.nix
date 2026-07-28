{
  description = "Radshop's NixOS configurations";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    
    # Add unstable nixpkgs for specific packages
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Add Home Manager as a flake input
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      # This makes home-manager use the same nixpkgs as your system
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs: {
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
          
          # Add overlay to use unstable claude-code
          {
            nixpkgs.overlays = [
              (final: prev: let
                unstable = import nixpkgs-unstable {
                  system = prev.system;
                  config.allowUnfree = true;
                };
              in {
                # Use claude-code from unstable channel with unfree allowed
                claude-code = unstable.claude-code;
              })
            ];
          }
        ];
        specialArgs = { inherit inputs; };
      };
      nixt460 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./t460/configuration.nix
          ./common
          
          # Add Home Manager's NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.miscguy = import ./t460/home.nix;
          }
          
          # Add overlay for unstable claude-code
          {
            nixpkgs.overlays = [
              (final: prev: let
                unstable = import nixpkgs-unstable {
                  system = prev.system;
                  config.allowUnfree = true;
                };
              in {
                # Use claude-code from unstable channel with unfree allowed
                claude-code = unstable.claude-code;
              })
            ];
          }
        ];
        specialArgs = { inherit inputs; };
      };
      nixt15g = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./t15g/configuration.nix
          ./common
          
          # Add Home Manager's NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.miscguy = import ./t15g/home.nix;
          }
          
          # Add overlay to use unstable claude-code
          {
            nixpkgs.overlays = [
              (final: prev: let
                unstable = import nixpkgs-unstable {
                  system = prev.system;
                  config.allowUnfree = true;
                };
              in {
                # Use claude-code from unstable channel with unfree allowed
                claude-code = unstable.claude-code;
              })
            ];
          }
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}
