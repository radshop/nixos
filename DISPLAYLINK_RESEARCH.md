# DisplayLink Research Notes

## Overview

This document summarizes our findings from attempting to implement DisplayLink drivers in NixOS 25.05. We're documenting this information for future reference while reverting to a stable system state.

## Implementation Attempts

We attempted several approaches to get DisplayLink working in NixOS 25.05:

1. **Initial Documentation** (824d52c): Created initial upgrade notes for DisplayLink after NixOS upgrade
2. **Driver Download** (0ea5a4e): Added DisplayLink drivers 5.8 and 6.1.1 to common/displaylink_drivers/
3. **Temporary Disabling** (314ab48): Commented out DisplayLink configuration during upgrade
4. **Incremental Re-enabling** (c7d29d3 → 27c583c): Re-enabled DisplayLink with configuration tweaks
5. **Configuration Fixes** (0589520): Attempted to fix black screen issues by modifying DisplayLink configuration

## Key Configuration Components

The following components were required for DisplayLink configuration:

1. **Kernel Modules**:
   ```nix
   boot.kernelModules = [ "evdi" ];
   boot.extraModulePackages = with config.boot.kernelPackages; [ evdi ];
   ```

2. **DisplayLink Service**:
   ```nix
   systemd.services.dlm.wantedBy = [ "multi-user.target" ];
   ```

3. **X11 Configuration**:
   ```nix
   services.xserver = {
     videoDrivers = [ "displaylink" "modesetting" ];
     displayManager.setupCommands = ''
       ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 1 0
       ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0
     '';
   };
   ```

4. **udev Rules**:
   ```nix
   services.udev.extraRules = ''
     SUBSYSTEM=="usb", ATTR{idVendor}=="17e9", MODE="0666"
     KERNEL=="card[0-9]*", SUBSYSTEM=="drm", ATTRS{vendor}=="0x17e9", TAG+="seat", TAG+="master-of-seat"
   '';
   ```

## Issues Encountered

1. **Black Screen Problems**: All screens (laptop and DisplayLink monitors) showed black screens with no login prompt when DisplayLink USB device was connected during boot.

2. **Driver Compatibility**: Potential incompatibility between DisplayLink drivers (both 5.8 and 6.1.1) and NixOS 25.05.

3. **Configuration Approach**: Tried both `displayManager.setupCommands` and `displayManager.sessionCommands` with varying results.

## Future Implementation Plan

For future implementation, consider:

1. Research DisplayLink compatibility with newer NixOS releases
2. Test in a non-critical environment first (VM or spare system)
3. Try newer DisplayLink drivers when available
4. Consider alternative display solutions if DisplayLink remains problematic

## Resources

- [DisplayLink Downloads](https://www.synaptics.com/products/displaylink-graphics/downloads/ubuntu)
- [NixOS Wiki - DisplayLink](https://nixos.wiki/wiki/DisplayLink)