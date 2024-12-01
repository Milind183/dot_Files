#!/bin/bash

# Variables
DWM_REPO="https://git.suckless.org/dwm"
DWM_DIR="$HOME/dwm"
PATCH_FOLDER="$HOME/dot_files/.config/dwm/patches"
CONFIG_H="$HOME/dot_files/.config/dwm/config.def.h"

# Clone dwm repository
if [ -d "$DWM_DIR" ]; then
    echo "dwm directory already exists. Skipping clone."
else
    git clone "$DWM_REPO" "$DWM_DIR"
    echo "Cloned dwm repository."
fi

# Copy the patch folder into the dwm directory
if [ -d "$PATCH_FOLDER" ]; then
    cp -r "$PATCH_FOLDER" "$DWM_DIR/patches"
    echo "Copied patch folder into dwm directory."
else
    echo "Patch folder not found at $PATCH_FOLDER."
    exit 1
fi

# Apply the vanity gaps patch
PATCH_FILE="$DWM_DIR/patches/dwm-cfacts-vanitygaps-6.4_combo.diff"

if [ -f "$PATCH_FILE" ]; then
    cd "$DWM_DIR" || exit
    patch -p1 < "$PATCH_FILE"
    echo "Applied vanity gaps patch."
else
    echo "Vanity gaps patch file not found at $PATCH_FILE."
    exit 1
fi

# Remove the existing config.def.h file and copy your custom config.def.h
if [ -f "$DWM_DIR/config.def.h" ]; then
    rm "$DWM_DIR/config.def.h"
    echo "Removed existing config.def.h."
fi

if [ -f "$CONFIG_H" ]; then
    cp "$CONFIG_H" "$DWM_DIR/config.def.h"
    echo "Copied your custom config.def.h to the dwm directory."
else
    echo "Custom config.def.h file not found at $CONFIG_H."
    exit 1
fi

# Build and install dwm
cd "$DWM_DIR" || exit
sudo make clean install
echo "dwm has been built and installed successfully."

