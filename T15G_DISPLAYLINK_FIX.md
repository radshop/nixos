# T15g DisplayLink Black Screen Fix

## Issue Description
After upgrading to NixOS 25.05, all screens (laptop and DisplayLink monitors) show black screens with no login prompt when DisplayLink USB device is connected during boot.

## First Fix Attempt

We've modified the configuration to use a simpler approach that resembles the older working setup:

1. Changed from `displayManager.setupCommands` to `displayManager.sessionCommands`
2. Simplified to only use one provider configuration command instead of two

### To Apply the Fix:

```bash
./rebuild-flake nixt15g
```

Then reboot the system.

## Verification

After rebooting, check if:
1. You can see the login screen on the laptop display
2. DisplayLink monitors are working properly

## Alternative Solutions (If First Fix Doesn't Work)

### Try Different Provider Numbers
If the screens are still black, we could try:

```nix
displayManager.sessionCommands = ''
  ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 1 0
'';
```

### Try Older DisplayLink Driver
We could try using the 5.8 driver instead of 6.1:

1. Edit the common/displaylink.nix file to use the 5.8 driver
2. Rebuild and reboot

### Try Booting Without DisplayLink Connected
1. Boot with DisplayLink disconnected
2. Login and connect DisplayLink afterward

### Fallback to Previous Generation
If needed, boot to a previous working generation (e.g., generation 60 or earlier)