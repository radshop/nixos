# NixOS Upgrade Checklist

## Pre-Upgrade Checklist

- [ ] Current system boots successfully
- [ ] All critical services running
- [ ] Recent backup exists
- [ ] Git repository is clean (committed/pushed)
- [ ] Document current package versions for critical tools

## Upgrade Process (24.11 → 25.05)

### 1. Test on VM First

- [ ] VM running current version (24.11)
- [ ] VM configuration matches production basics
- [ ] Create VM snapshot before upgrade

### 2. Update Flake

- [ ] Update nixpkgs URL to `nixos-25.05`
- [ ] Update home-manager to `release-25.05`
- [ ] Check for any deprecated options in release notes

### 3. Build Test

```bash
# Test build without switching
nixos-rebuild build --flake ".#nixvm01"
```

- [ ] Build completes without errors
- [ ] Review any warnings
- [ ] Check disk space (builds can be large)

### 4. Switch Test

```bash
# Apply the upgrade
nixos-rebuild switch --flake ".#nixvm01"
```

- [ ] Switch completes successfully
- [ ] System reboots properly
- [ ] User can login
- [ ] Desktop environment starts

### 5. Functionality Tests

- [ ] Network connectivity works
- [ ] Development tools available (vim, git, etc.)
- [ ] Home-manager configurations applied
- [ ] Custom packages/scripts work
- [ ] VM-specific features work (clipboard sharing, etc.)

### 6. Production Preparation

- [ ] Document any configuration changes needed
- [ ] Note any broken packages
- [ ] Identify workarounds for issues
- [ ] Update documentation

### 7. Production Upgrade

For each system (hq, t460):

- [ ] Create restore point/backup
- [ ] Run `nixos-rebuild build` first
- [ ] Review build output
- [ ] Run `nixos-rebuild switch`
- [ ] Test critical functionality
- [ ] Commit successful configuration

## Common Issues & Solutions

### Package Renamed/Removed
- Check NixOS 25.05 release notes
- Search for replacement packages
- Use overlay if needed

### Service Configuration Changed
- Review systemd service definitions
- Update configuration syntax
- Check for new required options

### Home-Manager Incompatibility
- Ensure home-manager matches NixOS version
- Check home-manager changelog
- Update home.nix configurations

### Build Failures
- Check disk space
- Clear old generations: `nix-collect-garbage -d`
- Review error messages carefully
- Search NixOS Discourse/GitHub issues

## Rollback Plan

### If upgrade fails:

1. **Immediate**: Use rollback
   ```bash
   nixos-rebuild switch --rollback
   ```

2. **At boot**: Select previous generation in GRUB

3. **From git**: 
   ```bash
   git checkout main
   nixos-rebuild switch --flake ".#hostname"
   ```

## Post-Upgrade Tasks

- [ ] Update flake.lock: `nix flake update`
- [ ] Clean old generations: `nix-collect-garbage -d`
- [ ] Update documentation
- [ ] Commit working configuration
- [ ] Tag release: `git tag upgrade-25.05`
- [ ] Update other systems

## Resources

- [NixOS 25.05 Release Notes](https://nixos.org/manual/nixos/stable/release-notes.html#sec-release-25.05)
- [NixOS Discourse](https://discourse.nixos.org/)
- [Home-Manager Changelog](https://github.com/nix-community/home-manager/blob/master/docs/release-notes/rl-2505.adoc)