# DisplayLink Upgrade Notes for nixhq

## Current Configuration

From `/home/miscguy/coding/nixos/hq/configuration.nix`:

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

1. **Download Latest DisplayLink Driver**
   - Go to [DisplayLink Downloads](https://www.displaylink.com/downloads/ubuntu)
   - Accept EULA and get the download link
   - Current version is 6.1

2. **Add Driver to Nix Store**
   ```bash
   nix-prefetch-url --name displaylink-610.zip https://www.synaptics.com/sites/default/files/exe_files/2024-10/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.1-EXE.zip
   ```
   - Note: Adjust filename and URL based on the latest version

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

## Fallback Plan
If DisplayLink doesn't work after upgrade:
1. Try different version of the driver
2. Temporarily switch to non-DisplayLink monitor setup
3. Consider using previous NixOS generation until fixed