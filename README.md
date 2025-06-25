# Radshop NixOS Configuration

This repository contains my NixOS configurations for multiple systems. It uses a modular approach that works both with traditional NixOS configuration and with the newer flakes system.

**Note**: In this documentation, `<nixos-repo>` refers to the location where you clone this repository:
- On most systems: `~/nixos`
- On nixhq: `~/coding/nixos`

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
   git clone https://github.com/radshop/nixos.git <nixos-repo>
   ```
3. Back up the existing configuration:
   ```bash
   sudo mv /etc/nixos /etc/nixos.bak
   ```
4. Symlink your repo to the NixOS configuration location:
   ```bash
   sudo ln -s <nixos-repo> /etc/nixos
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
   cd <nixos-repo>
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
   git clone https://github.com/radshop/nixos.git <nixos-repo>
   ```
3. Set up GitHub token for authentication (to avoid rate limiting):
   ```bash
   mkdir -p ~/.config/nixos
   echo 'GITHUB_TOKEN=ghp_your_token_here' > ~/.config/nixos/secrets.env
   chmod 600 ~/.config/nixos/secrets.env
   ```
4. First, apply the basic configuration to enable flakes:
   ```bash
   cd <nixos-repo>
   sudo nixos-rebuild switch -I nixos-config=./[hostname]/configuration.nix
   ```
5. Now you can use flakes for subsequent rebuilds:
   ```bash
   cd <nixos-repo>
   sudo nixos-rebuild switch --flake .#[hostname]
   ```

### Updating a Flakes-Based System

1. Update the repository:
   ```bash
   cd <nixos-repo>
   git pull
   ```
2. Update the flake lock file:
   ```bash
   source ~/.config/nixos/secrets.env  # Load GitHub token
   nix flake update
   ```
3. Rebuild your system:
   ```bash
   sudo nixos-rebuild switch --flake .#[hostname]
   ```

### Environment Variables for Secrets

To avoid GitHub API rate limiting and to keep sensitive information out of the Nix store, this configuration uses environment variables:

1. Create a secrets file if you haven't already:
   ```bash
   mkdir -p ~/.config/nixos
   touch ~/.config/nixos/secrets.env
   chmod 600 ~/.config/nixos/secrets.env
   ```

2. Add your GitHub token:
   ```bash
   echo 'GITHUB_TOKEN=ghp_your_token_here' > ~/.config/nixos/secrets.env
   ```

3. When running flake commands, source this file first:
   ```bash
   source ~/.config/nixos/secrets.env
   nix flake update
   ```

4. The system automatically configures Nix to use this token via the `github-token.nix` module

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
6. Keep secrets in environment variables, not in the Nix store

## Troubleshooting

If you encounter issues with flakes commands, ensure that the experimental features are enabled by checking your system configuration or by adding the `--extra-experimental-features` flag:

```bash
sudo nixos-rebuild switch --flake .#[hostname] --extra-experimental-features "nix-command flakes"
```

If you're having issues with GitHub rate limiting, make sure your GitHub token is correctly set up in `~/.config/nixos/secrets.env` and that you've sourced this file before running flake commands.
