# DisplayLink Upgrade Notes

## Current Configuration

Used by both nixhq and nixt15g in their respective configuration.nix files:

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

## Steps for DisplayLink After NixOS Upgrade

1. **Driver Versions Available**
   - **Version 5.8**: Older stable version that may work better with some hardware
   - **Version 6.1.1**: Latest version with newer features but may have compatibility issues
   - Both versions pre-downloaded in `./common/displaylink_drivers/`

2. **Manual Driver Setup**
   - The nix-prefetch-url method has proven unreliable
   - Drivers are already downloaded to `./common/displaylink_drivers/`:
     - `DisplayLink USB Graphics Software for Ubuntu5.8-EXE.zip`
     - `DisplayLink USB Graphics Software for Ubuntu6.1.1-EXE.zip`
   - Copy the appropriate driver to the Nix store manually if needed

3. **Configuration Updates to Consider**
   - Ensure DLM service is enabled:
     ```nix
     systemd.services.dlm.wantedBy = [ "multi-user.target" ];
     ```
   - If necessary, update provider source number in xrandr command if hardware detection changes

4. **Wayland Support (Optional)**
   - For Wayland/GNOME, may need additional configuration:
     ```nix
     environment.variables = {
       WLR_EVDI_RENDER_DEVICE = "/dev/dri/card1";  # Adjust card number as needed
     };
     ```

5. **Troubleshooting**
   - Check X11 configuration at `/etc/X11/xorg.conf.d/40-displaylink.conf`
   - Verify kernel modules are loaded: `lsmod | grep evdi`
   - Check service status: `systemctl status dlm`

## Post-Upgrade Verification
- Connect DisplayLink devices and verify they're detected
- Use `xrandr --listproviders` to see if DisplayLink is recognized
- Check system logs for any DisplayLink-related errors: `journalctl -u dlm`

## Version Selection Strategy
- **Try 5.8 first**: This is the stable version that has worked reliably in the past
- **If 5.8 fails**: Try 6.1.1 which may have better support for newer kernels
- Test on nixt15g (less critical system) before applying to nixhq

## Fallback Plan
If DisplayLink doesn't work after upgrade:
1. Try the other driver version (5.8 vs 6.1.1)
2. Temporarily switch to non-DisplayLink monitor setup
3. Consider using previous NixOS generation until fixed