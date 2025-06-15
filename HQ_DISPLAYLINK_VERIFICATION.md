# DisplayLink Verification Plan for HQ System

## Rebuild Command
```bash
./rebuild-flake nixhq
```

## Verification Steps After Reboot

1. **Check that kernel modules are loaded:**
   ```bash
   lsmod | grep evdi
   ```
   Expected output: Should show the evdi module

2. **Check DisplayLink service status:**
   ```bash
   systemctl status dlm
   ```
   Expected output: Service should be active (running)

3. **Check display providers:**
   ```bash
   xrandr --listproviders
   ```
   Expected output: Should show multiple providers including DisplayLink

4. **Verify providers are properly connected:**
   ```bash
   xrandr --verbose | grep "source output"
   ```

5. **Check for any DisplayLink errors in logs:**
   ```bash
   journalctl -u dlm --no-pager | tail -50
   ```

## Troubleshooting Steps

If displays are still black after reboot:

1. **Try adjusting provider numbers:**
   - If the current configuration uses `--setprovideroutputsource 1 0` and `--setprovideroutputsource 2 0`, you may need different provider numbers
   - Check the actual provider numbers using `xrandr --listproviders` and adjust accordingly

2. **Try using the older 5.8 driver:**
   - Edit common/displaylink.nix to point to the 5.8 driver instead of 6.1

3. **Check compatibility with your kernel:**
   ```bash
   uname -r
   ```
   - If using a very recent kernel, consider switching to a more stable kernel version

4. **Debugging with X logs:**
   ```bash
   cat /var/log/Xorg.0.log | grep -i displaylink
   cat /var/log/Xorg.0.log | grep -i evdi
   ```

5. **Temporarily disable DisplayLink to recover system:**
   - Boot with previous generation where DisplayLink worked
   - Or modify configuration to disable DisplayLink temporarily

Remember to reboot after each change to test the effects.