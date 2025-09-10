# Copilot Instructions for FixSvGravity Plugin

## Repository Overview
This repository contains a single SourcePawn plugin for SourceMod that fixes gravity prediction issues, prevents server crashes, and properly resets gravity on map end. The plugin addresses critical game mechanics problems related to sv_gravity ConVar handling and client-side gravity prediction in Source engine games.

**Plugin Name**: FixSvGravity  
**Version**: 2.0.0  
**Authors**: Botox, xen  
**Purpose**: Fixes gravity prediction, server crashes and resets gravity on map end

## Technical Environment
- **Language**: SourcePawn
- **Platform**: SourceMod 1.11.0+ (current target: 1.11.0-git6917)
- **Build Tool**: SourceKnight 0.1
- **Compiler**: SourcePawn compiler via SourceKnight
- **Dependencies**: sourcemod, sdktools

## Project Structure
```
├── .github/
│   ├── workflows/ci.yml          # CI/CD pipeline using SourceKnight
│   └── copilot-instructions.md   # This file
├── addons/sourcemod/scripting/
│   └── FixSvGravity.sp           # Main plugin source code
├── sourceknight.yaml             # Build configuration
└── .gitignore                    # Excludes build artifacts (.smx files)
```

## Build System
This project uses **SourceKnight** as the build tool:

- **Configuration**: `sourceknight.yaml` 
- **Build Target**: `FixSvGravity` (compiles to `FixSvGravity.smx`)
- **Output Directory**: `/addons/sourcemod/plugins`
- **CI/CD**: GitHub Actions workflow builds on Ubuntu 24.04

### Build Commands
The project is built via SourceKnight through GitHub Actions. Manual building requires:
1. SourceKnight installation: `pip install sourceknight`
2. Build command: `sourceknight build`

## Code Style & Standards
This project follows SourcePawn best practices:

### Formatting
- Indentation: 4 spaces (using tabs)
- Use `#pragma semicolon 1` and `#pragma newdecls required`
- Delete trailing spaces
- camelCase for local variables and function parameters
- PascalCase for function names  
- Prefix global variables with "g_"

### Variable Naming Conventions
- Global ConVars: `g_ConVar_VariableName`
- Global floats: `g_flVariableName`
- Global booleans: `g_bVariableName`
- Client arrays: `g_variableName[MAXPLAYERS + 1]`

### Code Organization
- Use descriptive variable and function names
- Implement proper initialization in `OnPluginStart()`
- Implement cleanup in `OnPluginEnd()` if necessary
- Use ConVar change hooks for dynamic configuration
- Use `OnGameFrame()` for performance-critical operations

## Plugin Functionality
The FixSvGravity plugin addresses several critical issues:

1. **Gravity Prediction Fixes**: Properly handles client-side gravity prediction
2. **Server Crash Prevention**: Prevents crashes related to invalid gravity values
3. **Map Transition Handling**: Resets gravity to default (800) on map end
4. **Ladder Interaction**: Special handling for players on ladders to prevent gravity conflicts
5. **Dynamic Gravity Updates**: Real-time gravity synchronization between server and clients

### Key Components
- **ConVar Monitoring**: Watches `sv_gravity` for changes and validates values
- **Client State Tracking**: Tracks individual client gravity states and ladder status
- **Gravity Replication**: Uses ConVar replication to sync gravity with clients
- **Frame-based Processing**: Efficient per-frame gravity state management

## Performance Considerations
- The plugin uses `OnGameFrame()` for real-time processing - be mindful of performance impact
- Client loops are optimized with early exits for invalid/bot clients
- Uses `RequestFrame()` for deferred gravity restoration after ladder exit
- Efficient string operations for gravity value conversion

## Development Guidelines

### Making Changes
1. **Understand the gravity system**: This plugin fixes complex game engine behaviors
2. **Test thoroughly**: Gravity changes can affect gameplay significantly
3. **Preserve existing logic**: The current implementation fixes known crashes and bugs
4. **Consider ladder interactions**: Special handling is required for ladder movement
5. **Validate ConVar changes**: Ensure gravity values remain within safe ranges

### Testing Approach
- Test with various gravity values (low, high, negative)
- Test ladder interactions with modified gravity
- Test map transitions and round restarts
- Test with multiple clients to ensure proper replication
- Monitor for memory leaks or performance issues

### Common Pitfalls
- Modifying gravity during ladder movement can cause issues
- Invalid gravity values (< 1) can crash the server
- Forgetting to handle map transitions can leave clients with wrong gravity
- Not properly tracking client states can cause desynchronization

## File Modification Guidelines
- **FixSvGravity.sp**: Main plugin logic - be extremely careful with changes
- **sourceknight.yaml**: Build configuration - update SourceMod version if needed
- **.github/workflows/ci.yml**: CI/CD pipeline - maintains automated building

## Debugging and Troubleshooting
- Use SourceMod's error logging for debugging
- Monitor ConVar replication using `sm_cvar sv_gravity` on clients
- Check client gravity states using `GetEntityGravity()`
- Test ladder movement scenarios thoroughly
- Verify gravity reset behavior on map changes

## Dependencies and Compatibility
- **SourceMod**: 1.11.0+ (tested with 1.11.0-git6917)
- **Game Support**: All Source engine games supported by SourceMod
- **Plugin Conflicts**: May conflict with other gravity-modifying plugins
- **ConVar Dependencies**: Requires `sv_gravity` ConVar access

## Release Process
The project uses automated releases via GitHub Actions:
- Pushes to main/master trigger builds
- Successful builds create "latest" releases
- Tagged versions create versioned releases
- Build artifacts are packaged as tar.gz files

When making changes, ensure the plugin version in the code matches any tags or releases.