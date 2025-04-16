{
  description = "Brother MFC-J995DW printer drivers for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { 
      inherit system;
      config.allowUnfree = true;
    };
  in {
    packages.${system} = {
      mfcj995dwlpr = pkgs.callPackage ./mfcj995dwlpr.nix {};
      mfcj995dwcupswrapper = pkgs.callPackage ./mfcj995dwcupswrapper.nix {};
      brscan4 = pkgs.callPackage ./brscan4.nix {};
      default = self.packages.${system}.mfcj995dwlpr;
    };

    nixosModules.default = { config, lib, pkgs, ... }: 
    let
      cfg = config.services.printing;
      scanCfg = config.hardware.sane;
    in {
      options = {
        # You could add additional options here if needed
      };

      config = {
        services.printing.drivers = with self.packages.${system}; [
          mfcj995dwlpr
          mfcj995dwcupswrapper
        ];

        hardware.sane.extraBackends = lib.optional scanCfg.enable self.packages.${system}.brscan4;
      };
    };
  };
}
