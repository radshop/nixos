# NixHQ DisplayLink Upgrade Plan

This document outlines the necessary steps to upgrade the NixHQ system to NixOS 25.05 while maintaining DisplayLink functionality, based on the successful migration of the T15g system.

## Current DisplayLink Configuration for HQ

The current configuration in hq/configuration.nix contains:

```nix
services.xserver = {
  # Configure keymap in X11
  xkb.layout = "us";
  xkb.variant = "";
  # Enable the X11 windowing system.
  enable = true;
  # displaylink
  videoDrivers = [ "displaylink" "modesetting" ];
  displayManager.sessionCommands = ''
    ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0
  '';
  # Enable the GNOME Desktop Environment.
  displayManager.gdm.enable = true;
  desktopManager.gnome.enable = true;
};
```

## Required Changes for NixOS 25.05

Based on our successful T15g upgrade, the following changes are required:

1. **Kernel Module Configuration**:
   ```nix
   # DisplayLink kernel modules
   boot.kernelModules = [ "evdi" ];
   boot.extraModulePackages = with config.boot.kernelPackages; [ evdi ];
   ```

2. **DisplayLink Service Configuration**:
   ```nix
   # Enable DisplayLink service
   systemd.services.dlm.wantedBy = [ "multi-user.target" ];
   ```

3. **DisplayLink Configuration**:
   ```nix
   nixpkgs.config.displaylink = {
     enable = true;
   };
   ```

4. **udev Rules for DisplayLink Devices**:
   ```nix
   services.udev.extraRules = ''
     # DisplayLink USB devices
     SUBSYSTEM=="usb", ATTR{idVendor}=="17e9", MODE="0666"
     KERNEL=="card[0-9]*", SUBSYSTEM=="drm", ATTRS{vendor}=="0x17e9", TAG+="seat", TAG+="master-of-seat"
   '';
   ```

5. **DisplayManager Commands**:
   ```nix
   displayManager.setupCommands = ''
     ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 1 0
     ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0
   '';
   ```

## Upgrade Process

1. **Driver Preparation**:
   - The DisplayLink 6.1 driver is already properly set up in the Nix store
   - The needed file (displaylink-610.zip) is properly copied and linked

2. **Upgrade Steps**:
   - Apply all the configuration changes above to hq/configuration.nix
   - Run the rebuild-flake script: `./rebuild-flake nixhq`
   - After upgrade completes, reboot the system
   - Verify DisplayLink is functioning correctly

3. **Verification Steps**:
   - Check loaded modules: `lsmod | grep evdi`
   - Check DisplayLink service: `systemctl status dlm`
   - Check display providers: `xrandr --listproviders`
   - Connect DisplayLink devices and verify they function

## Fallback Plan

If DisplayLink doesn't work after upgrade:
1. Temporarily boot without DisplayLink configuration
2. Try adjusting the provider source numbers in xrandr commands
3. Consider switching to the older DisplayLink 5.8 driver if needed

## Additional Notes

- The rebuild scripts have been improved to add a `--full` flag option for faster rebuilds
- For testing changes without updating packages: `./rebuild-flake nixhq`
- For full update including flatpak and garbage collection: `./rebuild-flake --full nixhq`