# Radshop NixOS Configuration

This repository contains my NixOS configurations for multiple systems. It uses a modular approach that works both with traditional NixOS configuration and with the newer flakes system.

## Repository Structure

- **common/** - Shared configurations used across all systems
  - **nix/** - Nix-specific settings including flakes support
- **[hostname]/** - Machine-specific configurations (e.g., `hq/`, `laptop/`, etc.)
- **flake.nix** - Entry point for flakes-based deployments

## Traditional Setup (Pre-Flakes)

### Setting Up a New NixOS System

1. Install NixOS using the standard installer
2. Clone this repository:
   ```bash
   git clone https://github.com/radshop/nixos.git ~/nixos
   ```
3. Back up the existing configuration:
   ```bash
   sudo mv /etc/nixos /etc/nixos.bak
   ```
4. Symlink your repo to the NixOS configuration location:
   ```bash
   sudo ln -s ~/nixos /etc/nixos
   ```
5. Create a symlink to your specific machine configuration:
   ```bash
   cd /etc/nixos
   sudo ln -s [hostname]/configuration.nix configuration.nix
   ```
6. Rebuild your system:
   ```bash
   sudo nixos-rebuild switch
   ```

### Updating an Existing System

1. Update the repository:
   ```bash
   cd ~/nixos
   git pull
   ```
2. Rebuild your system:
   ```bash
   sudo nixos-rebuild switch
   ```

## Flakes Setup (New Method)

### Prerequisites

The repository now includes flakes support. To enable flakes, the system must have experimental features enabled. This is automatically included in the common configuration at `common/nix/flakes.nix`.

### Setting Up a New NixOS System with Flakes

1. Install NixOS using the standard installer
2. Clone this repository:
   ```bash
   git clone https://github.com/radshop/nixos.git ~/nixos
   ```
3. First, apply the basic configuration to enable flakes:
   ```bash
   cd ~/nixos
   sudo nixos-rebuild switch -I nixos-config=./[hostname]/configuration.nix
   ```
4. Now you can use flakes for subsequent rebuilds:
   ```bash
   cd ~/nixos
   sudo nixos-rebuild switch --flake .#[hostname]
   ```

### Updating a Flakes-Based System

1. Update the repository:
   ```bash
   cd ~/nixos
   git pull
   ```
2. Update the flake lock file:
   ```bash
   nix flake update
   ```
3. Rebuild your system:
   ```bash
   sudo nixos-rebuild switch --flake .#[hostname]
   ```

### Adding a New System to Flakes

To add a new system to your flake.nix, edit the file and add a new entry to the `nixosConfigurations` attribute:

```nix
nixosConfigurations = {
  # Existing systems...
  
  newsystem = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";  # or appropriate architecture
    modules = [
      ./common
      ./newsystem
    ];
    specialArgs = { inherit inputs; };
  };
};
```

## Switching Between Traditional and Flakes Methods

You can use either the traditional or flakes-based method for any system in this repository. The configuration works with both approaches, so you can choose the method that works best for your workflow.

### Traditional Method
```bash
sudo nixos-rebuild switch
```

### Flakes Method
```bash
sudo nixos-rebuild switch --flake .#[hostname]
```

## Best Practices

1. Keep machine-specific configurations in the hostname directory
2. Put shared configurations in the common directory
3. Commit and push changes regularly
4. Use Git branches for experimental changes
5. Test configurations with `nixos-rebuild test` before applying them

## Troubleshooting

If you encounter issues with flakes commands, ensure that the experimental features are enabled by checking your system configuration or by adding the `--extra-experimental-features` flag:

```bash
sudo nixos-rebuild switch --flake .#[hostname] --extra-experimental-features "nix-command flakes"
```
