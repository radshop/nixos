# /etc/nixos/flake.nix
{
  description = "flake for nixhq";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.11";
    };
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      nixt460 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}

