# NixOS Configuration CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

Personal NixOS configuration repository managing multiple systems (desktops, laptops, VMs) with a declarative, reproducible approach using Nix flakes.

## Current Status (Last Updated: 2025-06-03)

### Active Work
- **STATUS**: Active configuration management
- **FOCUS**: Multi-system NixOS configurations
- **BLOCKERS**: None

### Systems Managed
- `hq` - Main system (nixhq)
- `t460` - ThinkPad T460 laptop  
- `t15g` - ThinkPad T15g
- `mac` - Mac configuration
- `vm01` - Virtual machine

## Technology Stack

- **OS**: NixOS 24.11
- **Configuration**: Nix language, Flakes
- **User Management**: Home Manager
- **Version Control**: Git with auto-commit on rebuild
- **Services**: Nextcloud, various development tools

## Architecture & Patterns

### Key Components
- `flake.nix` - Main flakes configuration
- `shared/` - Common configurations across systems
- `systems/` - Machine-specific configurations
- `common/` - Shared modules and settings
- `rebuild*.sh` - Automated rebuild scripts

### Design Patterns
- Declarative system configuration
- Modular configuration with overrides
- Automatic garbage collection (60 days)
- Git commits on successful rebuilds

### Configuration Flow
1. Edit configuration files
2. Run rebuild script for target system
3. Script rebuilds, collects garbage, commits changes
4. System updates with new configuration

## Important Files & Locations

### Core Files
- `flake.nix` - Flakes entry point
- `configuration.nix` - Traditional config entry
- `shared/miscguy.nix` - User configuration
- `rebuild.sh` - Main rebuild script

### System Configs
- `systems/hq/` - Main desktop
- `systems/t460/` - T460 laptop
- `systems/t15g/` - T15g laptop
- `systems/vm01/` - Virtual machine

### Shared Components
- `common/` - Shared system settings
- `shared/` - User and service configs

## Current Tasks & Questions

### Completed
- ✅ Multi-system flakes configuration
- ✅ Home Manager integration
- ✅ Automated rebuild scripts
- ✅ Brother printer support

### In Progress
- Maintaining system configurations
- Adding new packages as needed

### Open Questions
1. Migration strategy for remaining non-flakes configs?
2. Backup strategy for Nextcloud data?
3. Secrets management approach?

### Known Issues
- GitHub API rate limiting (mitigated with token)
- Conda on NixOS requires special handling

## Development Guidelines

### Making Changes
```bash
# Edit configuration
vim systems/hq/configuration.nix

# Rebuild specific system
./rebuild-hq.sh

# Or rebuild current system
./rebuild.sh
```

### Adding Packages
1. Add to appropriate configuration file
2. Run rebuild script
3. Changes auto-committed on success

### Testing Changes
- Use VM configuration for testing
- Rollback available via generations

## System Context

Personal infrastructure management for:
- Development workstations
- Laptop configurations
- Virtual machines
- Self-hosted services (Nextcloud)

All managed declaratively through Nix for reproducibility.

## Special Considerations

- **Immutable System**: Changes require rebuild
- **Declarative**: Everything in configuration files
- **Reproducible**: Same config = same system
- **Rollback**: Previous generations available

## Work Style & Efficiency

**SEE MASTER DOCUMENTATION**: `/home/miscguy/coding/CLAUDE.md` for work style and efficiency principles

### Key Principle
NixOS configurations are declarative - always verify exact module options and syntax before making changes. The Nix language is functional and strongly typed.

## Quick Start Commands

**"go"** - When user types this, Claude should:
1. Check this CLAUDE.md and recent commits
2. Review current system configurations
3. Check for any failed rebuilds
4. Report current status
5. Wait for instructions