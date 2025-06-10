{ config, lib, pkgs, ... }:

{
  # Only add the EnvironmentFile if it exists
  systemd.services.nix-daemon.serviceConfig = lib.mkIf (builtins.pathExists "/home/${config.users.users.miscguy.name}/.config/nixos/secrets.env") {
    # Load environment variables from file
    EnvironmentFile = "/home/${config.users.users.miscguy.name}/.config/nixos/secrets.env";
  };
  
  # Make nix CLI commands use the same token by setting it in /etc/nix/nix.conf
  system.activationScripts.nix-github-token = {
    text = ''
      if [ -f /home/${config.users.users.miscguy.name}/.config/nixos/secrets.env ]; then
        # Extract token from env file
        token=$(grep GITHUB_TOKEN /home/${config.users.users.miscguy.name}/.config/nixos/secrets.env | cut -d '=' -f2)
        
        # Add to nix.conf if token exists
        if [ ! -z "$token" ]; then
          echo "Setting GitHub token in nix.conf"
          ${pkgs.gnused}/bin/sed -i '/access-tokens = github.com=/d' /etc/nix/nix.conf
          echo "access-tokens = github.com=$token" >> /etc/nix/nix.conf
        fi
      fi
    '';
    deps = [];
  };
}
