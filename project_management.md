# Project Management - NixOS Configuration

## Active Workstreams

### 1. System Configuration Management
**Status:** Ongoing Maintenance  
**Priority:** Medium  
**Timeline:** Continuous

#### Current State
- ✅ 5 systems configured with flakes
- ✅ Automated rebuild scripts
- ✅ Home Manager integration
- ⏳ Regular updates and maintenance

#### Next Actions
- [ ] Review and update package versions
- [ ] Evaluate new NixOS 25.05 when available
- [ ] Document any system-specific quirks
- [ ] Consider secrets management solution

#### Dependencies
- NixOS release cycle
- Upstream package updates
- Hardware compatibility

## Todo List

### Immediate (This Week)
- [ ] Review current configurations for cleanup opportunities
- [ ] Update any outdated packages
- [ ] Check for security updates

### Short Term (This Month)
- [ ] Document configuration patterns
- [ ] Optimize rebuild times
- [ ] Review garbage collection policy

### Long Term (Backlog)
- [ ] Full secrets management implementation
- [ ] Automated testing of configurations
- [ ] CI/CD for configuration validation
- [ ] Backup automation for Nextcloud

## Key Files & Locations

### Documentation
- Project guidance: `CLAUDE.md`
- Original docs: `README.md`
- Flakes guide: `ReadmeFlakes.md`

### Core Configuration
- Entry point: `flake.nix`
- Legacy entry: `configuration.nix`
- User config: `shared/miscguy.nix`

### System-Specific
- Desktop: `systems/hq/`
- Laptops: `systems/t460/`, `systems/t15g/`
- Virtual: `systems/vm01/`

## Recent Activity

### 2025-06-09 - Fixed nix-daemon error with flakes on t460
- **Issue:** nix-daemon service was failing to start when flakes were enabled
  - Error: `nix-daemon.service: Failed to load environment files: No such file or directory`
  - Occurred on both NixOS 24.11 and 25.05
  - Caused by missing `secrets.env` file required in `github-token.nix`
- **Solution:** Modified `common/nix/github-token.nix` to make the environment file optional
  - Used `lib.mkIf (builtins.pathExists "...")` to only add the EnvironmentFile if it exists
  - This prevents the nix-daemon from failing when the file is missing
  - Allows flakes to work on systems without GitHub token configuration
- **Changes:**
  1. Updated `common/nix/github-token.nix` to check if secrets.env exists before requiring it
  2. Re-enabled flakes in `t460/configuration.nix`
- **Next Steps:**
  - Test rebuild on t460 with flakes enabled
  - Consider similar conditional checks for other configuration files that might not exist on all systems

### Last Session
- Cloned repository
- Added to master project
- Created documentation structure

### Recent System Changes
- [Check git log for actual changes]

## Blockers & Questions

### Active Blockers
None currently - mature configuration

### Open Questions
1. Best approach for secrets management in NixOS?
2. Should printer configs be modularized?
3. Nextcloud backup strategy?
4. Migration timeline for remaining non-flakes configs?

## Success Metrics

### System Reliability
- [ ] All systems rebuild without errors
- [ ] Quick rollback capability maintained
- [ ] No configuration drift between systems
- [ ] Consistent user experience across machines

### Project Goals
- Declarative infrastructure for all systems
- Easy system recovery from configuration
- Minimal maintenance overhead
- Learning platform for NixOS best practices

## Architecture Notes

### Why NixOS?
- Reproducible system configurations
- Atomic updates and rollbacks
- Declarative system management
- No configuration drift

### Key Design Decisions
1. **Flakes** - Modern, reproducible builds
2. **Home Manager** - User-level declarative config
3. **Modular Structure** - Shared + system-specific
4. **Auto-commit** - Track all configuration changes

### Technical Patterns
- Common configurations in `shared/`
- System overrides in `systems/*/`
- Automated rebuilds with garbage collection
- Git history as configuration changelog

## Integration with Other Projects

This is infrastructure supporting all development:
- Consistent dev environment across machines
- Quick provisioning of new systems
- Reliable rollback for experiments

## Notes
Classic example of "infrastructure as code" - entire system state captured in version-controlled configuration files. Each rebuild creates an immutable system generation.