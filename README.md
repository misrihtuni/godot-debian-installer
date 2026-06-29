# Godot Engine Installer for Linux Systems

This repository contains scripts for installing Godot Game Engine system-wide
in Linux environments.

## Usage

1. Download the script for the desired Godot version.
2. Use `chmod +x ./godot-VERSION-installer.sh` to enable running the script as a
   program.
3. To install the application, use `./godot-VERSION-installer.sh`.
   To remove the application, use `./godot-VERSION-installer.sh remove`.

> [!IMPORTANT]
> Replace `VERSION` with the actual version number. For example, `./godot-4.7-installer.sh`.

> [!NOTE]
> You can have multiple versions installed at the same time, they won't overlap.

## Planned Features

- [ ] Common install directory (`/opt/godot/<VERSION>` instead of `/opt/godot-<VERSION>`)
- [ ] Option to add the install location to `PATH`
- [ ] Version selection (removes the need for different scripts)
- [ ] Costomizable install location (might be unnecessary for system-wide installs)
