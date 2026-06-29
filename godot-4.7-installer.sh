# Installer script by Miska Rihu <miska.rihu@tuni.fi>
# The installer is licensed under the MIT License and is provided AS IS with NO WARRANTY.
# Godot Engine License: https://github.com/godotengine/godot/blob/bc192293b13a8891cb8739a36d8c0736a5c4c4b8/LICENSE.txt
##############################################################################

#!/usr/bin/env bash
set -euo pipefail


##############################################################################
# Exit codes.
##############################################################################

EXIT_NO_ROOT_PRIVILEGES=1
EXIT_WGET_NOT_INSTALLED=2
EXIT_UNZIP_NOT_INSTALLED=3
EXIT_DOWNLOAD_FAILED=4
EXIT_ABORTED_BY_USER=5
EXIT_EXTRACT_FAILED=6
EXIT_ABORT_UNINSTALL_NOT_INSTALLED=7


##############################################################################
# Constants.
##############################################################################

PRODUCT_VERSION="4.7"
PRODUCT_NAME="Godot Engine $PRODUCT_VERSION"

# Download links.
ENGINE_DOWNLOAD_LINK="https://downloads.godotengine.org/?version=$PRODUCT_VERSION&flavor=stable&slug=mono_linux_x86_64.zip&platform=linux.64"
ICON_DOWNLOAD_LINK="https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/misc/logo/icon.svg"

# Temp files.
TEMP_DIR="/tmp/godot-installer"
TEMP_ICON="$TEMP_DIR/icon.svg"
TEMP_ENGINE_ARCHIVE="$TEMP_DIR/godot.zip"
TEMP_EXTRACTED_FILES="$TEMP_DIR/extracted-files"

# Final installation paths.
INSTALL_DIR="/opt/godot-$PRODUCT_VERSION"
EXEC_PATH="$INSTALL_DIR/godot-$PRODUCT_VERSION.x86_64"
ICON_PATH="$INSTALL_DIR/icon.svg"

# Shortcut paths.
SHORTCUTS_DIR="/usr/share/applications"
SHORTCUT_FILE="godot-$PRODUCT_VERSION.desktop"
SHORTCUT_PATH="$SHORTCUTS_DIR/$SHORTCUT_FILE"


##############################################################################
# File deletion functions.
##############################################################################

# Deletes the temp directory and its contents if present.
delete_temp_files_if_exists() {
    if [ -d "$TEMP_DIR" ]; then
        rm -r "$TEMP_DIR"
    fi
}

# Deletes the install directory and all of its contents if present.
delete_engine_files_if_exists() {
    if [ -d "$INSTALL_DIR" ]; then
        echo "Deleting '$INSTALL_DIR/*'."
        rm -r "$INSTALL_DIR"
    fi
}

# Deletes the application launcher if present.
delete_launcher_if_exists() {
    if [ -e "$SHORTCUT_PATH" ]; then
        echo "Deleting '$SHORTCUT_PATH'."
        rm $SHORTCUT_PATH
    fi
}


##############################################################################
# Utility functions.
##############################################################################

# Checks if the given command exists.
is_command_installed() {
    local command="$1"
    if [ $(which $command) = "" ]; then
        false
    else
        true
    fi
}

# Prompts for confirmation using the given prompt text.
prompt_confirmation() {
    local prompt="$1"
    while true; do
        read -p "$prompt: " yn
        case $yn in
            [Yy] ) true; return;;
            [Nn] ) false; return;;
            * ) echo "Invalid response. Please answer y or n.";;
        esac
    done
}

# Deletes temp files and exits the installer with the given exit code.
abort() {
    delete_temp_files_if_exists
    echo "Aborted."
    exit $1
}

# Checks if the product is already installed.
is_already_installed() {
    if [ -d "$INSTALL_DIR" ]; then
        true
    else
        false
    fi
}


##############################################################################
# Uninstaller.
##############################################################################

# Performs the uninstallation.
uninstall() {
    delete_engine_files_if_exists
    delete_launcher_if_exists
}

interactive_uninstall() {
    if ! is_already_installed; then
        echo "The product is not installed on this system."
        abort $EXIT_ABORT_UNINSTALL_NOT_INSTALLED
    fi

    echo "Welcome to $PRODUCT_NAME uninstaller."
    echo
    echo "This script will delete all the files at the following locations:"
    echo "- Install directory: $INSTALL_DIR"
    echo "- Launcher file: $SHORTCUT_PATH"
    echo
    echo "Please note that this action cannot be undone."
    echo

    if ! prompt_confirmation "Do you wish to continue? [y/n]"; then
        abort $EXIT_ABORTED_BY_USER
    fi

    echo "Uninstalling $PRODUCT_NAME."
    uninstall

    echo "$PRODUCT_NAME has been uninstalled from the system."
}


##############################################################################
# Installer.
##############################################################################

# Ensures that the temp dir exists.
# If one is already present, deletes it first and then creates a new one.
ensure_empty_temp_dir() {
    delete_temp_files_if_exists
    mkdir -p "$TEMP_DIR"
}

# Download the application icon using wget.
download_icon() {
    wget --quiet --show-progress "$ICON_DOWNLOAD_LINK" -O "$TEMP_ICON"
}

# Download the engine files using wget.
download_engine() {
    wget --quiet --show-progress "$ENGINE_DOWNLOAD_LINK" -O "$TEMP_ENGINE_ARCHIVE"
}

# Extracts the downloaded archive to the install root.
extract_engine_files() {
    if [ ! -d "$TEMP_EXTRACTED_FILES" ]; then
        mkdir -p "$TEMP_EXTRACTED_FILES"
    fi

    unzip -q "$TEMP_ENGINE_ARCHIVE" -d "$TEMP_EXTRACTED_FILES"
}

ensure_install_dir_exists() {
    if [ ! -d "$INSTALL_DIR" ]; then
        mkdir -p "$INSTALL_DIR"
    fi
}

copy_files() {
    local last_dir="$(pwd)"
    if [ -e "$TEMP_ICON" ]; then
        cp "$TEMP_ICON" "$INSTALL_DIR"
    fi

    cp -r $TEMP_EXTRACTED_FILES/G*/* $INSTALL_DIR
    mv $INSTALL_DIR/*.x86_64 $EXEC_PATH
}


# Creates a launcher for the application in the applications menu.
create_launcher() {
    local temp_shortcut_path="$TEMP_DIR/$SHORTCUT_FILE"

    touch $temp_shortcut_path
    echo "[Desktop Entry]" > $temp_shortcut_path
    echo "Name=$PRODUCT_NAME" >> $temp_shortcut_path
    echo "Exec=$EXEC_PATH" >> $temp_shortcut_path
    echo "Terminal=false" >> $temp_shortcut_path
    echo "Type=Application" >> $temp_shortcut_path
    echo "Icon=$ICON_PATH" >> $temp_shortcut_path
    echo "Categories=Development;" >> $temp_shortcut_path
    echo "StartupNotify=true" >> $temp_shortcut_path
    echo "" >> $temp_shortcut_path

    delete_launcher_if_exists
    cp $temp_shortcut_path $SHORTCUT_PATH
}

# Performs the installation.
interactive_install() {
    if ! is_command_installed "wget"; then
        echo "Installation cannot continue: wget not installed."
        abort $EXIT_WGET_NOT_INSTALLED
    fi

    if ! is_command_installed "unzip"; then
        echo "Installation cannot continue: unzip not installed."
        abort $EXIT_UNZIP_NOT_INSTALLED
    fi

    echo "Welcome to $PRODUCT_NAME installer."
    echo
    echo "This script will download and install $PRODUCT_NAME to your system."
    echo "- Install location: $INSTALL_DIR"
    echo "- Launcher location: $SHORTCUT_PATH"
    echo
    echo "Please note the following before you continue:"
    echo "- This installer is provided AS IS with ABSOLUTELY NO WARRANTY."
    echo "- This installer requires wget and unzip to function properly."
    echo "- Running the installed program requires .NET SDK 8.0 or newer to be "
    echo "  installed on the system. This will not be done automatically."
    echo


    if ! prompt_confirmation "Do you wish to continue? [y/n]"; then
        abort $EXIT_ABORTED_BY_USER
    fi

    if is_already_installed; then
        echo "The installer detected an already existing installation."

        if ! prompt_confirmation "Do you wish to fully reinstall the application? [y/n]"; then
            abort $EXIT_ABORTED_BY_USER
        fi

        echo "Removing previous installation."
        uninstall
    fi

    ensure_empty_temp_dir

    echo "Downloading files."

    if ! download_engine; then
        echo "ERROR: Could not download install files."
        abort $EXIT_DOWNLOAD_FAILED
    fi

    if ! download_icon; then
        echo "WARNING: Could not download application icon."
    fi

    echo "Extracting downloaded archive."
    if ! extract_engine_files; then
        echo "ERROR: Failed to extract the downloaded archive."
        abort $EXIT_EXTRACT_FAILED
    fi

    echo "Copying files to '$INSTALL_DIR'."
    ensure_install_dir_exists
    copy_files

    echo "Creating launcher."
    if ! create_launcher; then
        echo "WARNING: Failed to create application launcher."
    fi

    echo "Cleaning up."
    delete_temp_files_if_exists

    echo "$PRODUCT_NAME has been installed."
}


##############################################################################
# Script entry point.
##############################################################################

# Check root privileges.
if [ "$(id -u)" -eq 0 ]; then
    if [ $# -eq 0 ]; then
        interactive_install
    else
        if [ $# -eq 1 ] && [ "$1" = "remove" ]; then
            interactive_uninstall
        else
            echo "To install the application, run this script without arguments."
            echo "To uninstall the application, run this script with the 'remove' argument."
            exit
        fi
    fi
else
    echo "This installer must be run with root privileges (as root or via sudo)."
    abort $EXIT_NO_ROOT_PRIVILEGES
fi

##############################################################################
# EOF
