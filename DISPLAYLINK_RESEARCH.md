# DisplayLink Research Notes

## Overview

This document summarizes our findings from attempting to implement DisplayLink drivers in NixOS 25.05. We're documenting this information for future reference while working toward a stable solution.

## Implementation Attempts

We attempted several approaches to get DisplayLink working in NixOS 25.05:

1. **Initial Documentation** (824d52c): Created initial upgrade notes for DisplayLink after NixOS upgrade
2. **Driver Download** (0ea5a4e): Added DisplayLink drivers 5.8 and 6.1.1 to common/displaylink_drivers/
3. **Temporary Disabling** (314ab48): Commented out DisplayLink configuration during upgrade
4. **Incremental Re-enabling** (c7d29d3 → 27c583c): Re-enabled DisplayLink with configuration tweaks
5. **Configuration Fixes** (0589520): Attempted to fix black screen issues by modifying DisplayLink configuration
6. **Advanced Configuration** (latest): Added enhanced DisplayLink support with hot-plug handling and recovery tools

## Key Configuration Components

The following components were required for DisplayLink configuration:

1. **Kernel Modules**:
   ```nix
   boot.kernelModules = [ "evdi" ];
   boot.extraModulePackages = with config.boot.kernelPackages; [ evdi ];
   ```

2. **Enhanced DisplayLink Service**:
   ```nix
   systemd.services.dlm = {
     wantedBy = [ "multi-user.target" ];
     after = [ "multi-user.target" "systemd-logind.service" "systemd-modules-load.service" ];
     before = [ "display-manager.service" ];
     
     serviceConfig = {
       Restart = "always";
       RestartSec = lib.mkForce 3;
       ExecStartPre = "${pkgs.kmod}/bin/modprobe evdi";
     };
   };
   ```

3. **X11 Configuration with Improved Reliability**:
   ```nix
   services.xserver = {
     videoDrivers = [ "displaylink" "modesetting" ];
     
     displayManager.setupCommands = ''
       # Wait for DisplayLink to be ready
       for i in {1..10}; do
         if ${pkgs.util-linux}/bin/lsmod | grep -q evdi; then
           break
         fi
         sleep 1
       done
       
       # Configure DisplayLink outputs with fallbacks
       ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 1 0 || true
       ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0 || true
       
       # Optional: Set a primary display to avoid black screen
       ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --primary || true
     '';
   };
   ```

4. **Enhanced udev Rules with Hot-plug Support**:
   ```nix
   services.udev.extraRules = ''
     # DisplayLink USB devices
     SUBSYSTEM=="usb", ATTR{idVendor}=="17e9", MODE="0666"
     KERNEL=="card[0-9]*", SUBSYSTEM=="drm", ATTRS{vendor}=="0x17e9", TAG+="seat", TAG+="master-of-seat"
     
     # Restart DisplayLink service on USB events
     SUBSYSTEM=="usb", ATTR{idVendor}=="17e9", ACTION=="add", RUN+="${pkgs.systemd}/bin/systemctl restart dlm.service"
     SUBSYSTEM=="usb", ATTR{idVendor}=="17e9", ACTION=="remove", RUN+="${pkgs.systemd}/bin/systemctl restart dlm.service"
   '';
   ```

5. **Recovery Script**:
   ```nix
   environment.systemPackages = with pkgs; [
     # Other packages...
     
     # DisplayLink reset script for recovery from black screens
     (writeShellScriptBin "displaylink-reset" ''
       #!/bin/bash
       echo "Restarting DisplayLink..."
       
       # Restart the DisplayLink service
       sudo systemctl restart dlm
       sleep 2
       
       # Reload the evdi module
       sudo modprobe -r evdi
       sleep 1
       sudo modprobe evdi
       sleep 2
       
       # Reconfigure displays
       export DISPLAY=:0
       ${xorg.xrandr}/bin/xrandr --setprovideroutputsource 1 0 || true
       ${xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0 || true
       
       echo "DisplayLink reset complete"
     '')
   ];
   ```

## Issues Encountered

1. **Black Screen Problems**: All screens (laptop and DisplayLink monitors) showed black screens with no login prompt when DisplayLink USB device was connected during boot.

2. **Driver Compatibility**: Potential incompatibility between DisplayLink drivers (both 5.8 and 6.1.1) and NixOS 25.05.

3. **Configuration Approach**: Tried both `displayManager.setupCommands` and `displayManager.sessionCommands` with varying results.

4. **Timing Issues**: Discovered that proper service ordering and waiting for module initialization improves reliability.

## Current Status

We've made progress with the advanced configuration that includes:

1. Enhanced service definitions with proper ordering
2. Wait-and-retry logic for display initialization
3. Hot-plug support for attaching/detaching DisplayLink devices
4. Recovery script for fixing DisplayLink issues without rebooting

Testing is ongoing to determine if these enhancements resolve the stability issues.

## Future Implementation Plan

For future implementation, consider:

1. Research DisplayLink compatibility with newer NixOS releases
2. Test in a non-critical environment first (VM or spare system)
3. Try newer DisplayLink drivers when available
4. Consider alternative display solutions if DisplayLink remains problematic

## Resources

- [DisplayLink Downloads](https://www.synaptics.com/products/displaylink-graphics/downloads/ubuntu)
- [NixOS Wiki - DisplayLink](https://nixos.wiki/wiki/DisplayLink)