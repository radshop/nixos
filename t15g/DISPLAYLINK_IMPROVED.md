# T15g DisplayLink Improvements

This document outlines the changes made to improve DisplayLink functionality on the T15g system, addressing the black screen issues that occur during boot with DisplayLink connected.

## Implemented Changes

The following improvements have been made to the DisplayLink configuration:

1. **Enhanced DisplayLink Service Configuration**
   - Proper boot sequence ordering (starts after system services but before display manager)
   - Automatic module loading with ExecStartPre
   - Improved restart and recovery capabilities

2. **Improved Display Manager Integration**
   - Wait and retry logic for DisplayLink initialization
   - Fallback mechanisms for provider configuration
   - Primary display setting to prevent black screens

3. **Hot-plug Support**
   - Enhanced udev rules to detect DisplayLink USB events
   - Automatic service restart on connect/disconnect
   - Dedicated hotplug handler service

4. **Recovery Tool**
   - Added `displaylink-reset` command for manual recovery
   - Can be run from TTY (Ctrl+Alt+F2) if you get a black screen
   - Reloads modules and reconfigures displays

## How to Use

### Normal Usage

1. After applying these changes, run: `./rebuild-flake nixt15g`
2. Try booting with DisplayLink connected - it should now work correctly
3. If hot-plugging, the system should automatically detect and configure DisplayLink

### Recovery from Black Screen

If you still experience black screens:

1. Press Ctrl+Alt+F2 to switch to a TTY
2. Login with your username and password
3. Run `displaylink-reset`
4. Switch back to graphical mode with Ctrl+Alt+F1

### Fallback Plan

If DisplayLink still doesn't work properly:

1. Boot without DisplayLink connected
2. Login normally
3. Connect DisplayLink
4. Run `displaylink-reset` if needed

## Technical Details

### Service Dependencies

The updated configuration properly orders the services:
```
systemd-modules-load.service → dlm.service → display-manager.service
```

### Display Detection

The system now uses a retry mechanism with a 10-second timeout to ensure DisplayLink is ready before X11 starts, and configures both potential provider sources (1 and 2).

### Module Loading

The evdi kernel module is now:
- Loaded at boot via kernel modules list
- Verified before DisplayLink service starts
- Reloaded as needed by the reset script