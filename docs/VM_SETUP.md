# NixOS VM Setup Guide

This guide documents how to set up a NixOS VM for testing configuration changes before applying them to production systems.

## Purpose

The VM (nixvm01) serves as a testing environment for:
- NixOS version upgrades (e.g., 24.11 → 25.05)
- Configuration changes
- New package installations
- System-wide modifications

## VM Requirements

- **Hypervisor**: QEMU/KVM with virt-manager (or VirtualBox/VMware)
- **Resources**:
  - RAM: 4-8GB recommended
  - Disk: 20-40GB
  - CPU: 2-4 cores
- **Network**: NAT or bridged networking

## Initial Setup

### 1. Download NixOS ISO

Download the current stable release (24.11) from [nixos.org/download](https://nixos.org/download).

### 2. Create VM

Using virt-manager:
```bash
virt-manager
```

1. Click "Create a new virtual machine"
2. Choose "Local install media (ISO)"
3. Browse to the NixOS ISO
4. Set RAM (4096MB minimum)
5. Create disk (20GB minimum)
6. Name: `nixvm01`
7. Check "Customize configuration before install"
8. In configuration:
   - Change Video to QXL
   - Add Spice server for better integration
   - Use UEFI if available (or BIOS)

### 3. Install NixOS

1. Boot from ISO
2. At prompt: `sudo -i`
3. Partition disk:
   ```bash
   # For UEFI:
   parted /dev/vda -- mklabel gpt
   parted /dev/vda -- mkpart primary 512MB -8GB
   parted /dev/vda -- mkpart primary linux-swap -8GB 100%
   parted /dev/vda -- mkpart ESP fat32 1MB 512MB
   parted /dev/vda -- set 3 esp on
   
   # Format:
   mkfs.ext4 -L nixos /dev/vda1
   mkswap -L swap /dev/vda2
   mkfs.fat -F 32 -n boot /dev/vda3
   
   # Mount:
   mount /dev/disk/by-label/nixos /mnt
   mkdir -p /mnt/boot
   mount /dev/disk/by-label/boot /mnt/boot
   swapon /dev/disk/by-label/swap
   ```

4. Generate config:
   ```bash
   nixos-generate-config --root /mnt
   ```

5. Basic configuration:
   ```bash
   nano /mnt/etc/nixos/configuration.nix
   ```
   
   Set hostname to `nixvm01` and enable NetworkManager.

6. Install:
   ```bash
   nixos-install
   # Set root password when prompted
   reboot
   ```

### 4. Post-Install Configuration

1. Login as root
2. Create user:
   ```bash
   useradd -m -G wheel miscguy
   passwd miscguy
   ```

3. Enable sudo for wheel group in configuration.nix

4. Clone this repository:
   ```bash
   cd /etc/nixos
   rm -rf *
   git clone https://github.com/[your-repo]/nixos-config.git .
   ```

5. First rebuild with flakes:
   ```bash
   nixos-rebuild switch --flake ".#nixvm01"
   ```

## Testing Upgrades

### Testing 25.05 Upgrade

1. Switch to test branch:
   ```bash
   cd /etc/nixos
   git checkout upgrade-to-25.05
   ```

2. Use the 25.05 flake:
   ```bash
   # Test build without switching
   nixos-rebuild build --flake ".#nixvm01" --override-input nixpkgs github:nixos/nixpkgs/nixos-25.05
   
   # If successful, switch
   nixos-rebuild switch --flake ".#nixvm01" --override-input nixpkgs github:nixos/nixpkgs/nixos-25.05
   ```

3. Or use the prepared flake-25.05.nix:
   ```bash
   mv flake.nix flake-24.11.nix
   mv flake-25.05.nix flake.nix
   nixos-rebuild switch --flake ".#nixvm01"
   ```

## VM-Specific Optimizations

The vm01 configuration includes several optimizations:

- **Guest tools**: `qemuGuest`, `spice-vdagent` for better integration
- **Video driver**: QXL for better performance
- **Documentation disabled**: Saves space and build time
- **Faster boot**: Disabled journaling FS checks

## Rollback Procedures

If something goes wrong:

1. **Immediate rollback**:
   ```bash
   # List generations
   nixos-rebuild list-generations
   
   # Switch to previous
   nixos-rebuild switch --rollback
   ```

2. **Boot menu**: Select previous generation from GRUB

3. **Git rollback**:
   ```bash
   git checkout main
   nixos-rebuild switch --flake ".#nixvm01"
   ```

## Tips

- Take VM snapshots before major changes
- Use `nixos-rebuild build` to test without switching
- Keep the VM configuration minimal for faster rebuilds
- Document any VM-specific workarounds

## Troubleshooting

### Network Issues
- Ensure NetworkManager is enabled
- Check VM network settings (NAT vs bridged)

### Display Issues
- Install `spice-vdagent` package
- Use QXL video driver
- Enable spice channel in virt-manager

### Performance
- Allocate sufficient RAM (4GB+)
- Use virtio drivers where possible
- Enable KVM acceleration