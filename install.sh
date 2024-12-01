#!/bin/bash

# Variables
DWM_REPO="https://git.suckless.org/dwm"
DWM_DIR="$HOME/dwm"
PATCH_FOLDER="$HOME/dot_Files/.config/dwm/patches"
CONFIG_H="$HOME/dot_Files/.config/dwm/config.def.h"

# Function to check if yay is installed
check_yay() {
    if ! command -v yay &> /dev/null; then
        echo "yay is not installed. Installing yay..."
        sudo pacman -S --noconfirm base-devel git
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay || exit
        makepkg -si --noconfirm
        cd - || exit
        rm -rf /tmp/yay
        echo "yay has been installed successfully."
    else
        echo "yay is already installed."
    fi
}

# Function to install dependencies
install_dependencies() {
    echo "Installing system dependencies..."
    sudo pacman -S --noconfirm xorg-server libx11 libxft libxinerama gcc make \
                     python libxkbcommon fontconfig libxcb neovim python-pynvim \
                     lua libtermkey libvterm unibilium tree-sitter cmake ninja pkgconf \
                     picom libconfig libev libgl libepoxy pcre2 pixman xcb-util-image \
                     xcb-util-renderutil dbus xorg-xprop xorg-xwininfo rtkit meson git \
                     xorgproto libxext
}

# Function to install AUR dependencies
install_aur_dependencies() {
    echo "Installing AUR dependencies..."
    yay -S --noconfirm msgpack
}

# Function to install fonts (Fira, Hack, Source JetBrains)
install_fonts() {
    echo "Installing fonts..."
    yay -S --noconfirm ttf-fira-code ttf-hack ttf-jetbrains-mono
}

# Function to clone dwm repo and apply patch
install_dwm() {
    # Clone dwm repository if not already cloned
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

    # Remove the existing config.def.h file and copy your custom config
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
}

# Main function that runs all steps
main() {
    # Check and install yay if necessary
    check_yay

    # Install system dependencies
    install_dependencies

    # Install AUR dependencies
    install_aur_dependencies

    # Install fonts
    install_fonts

    # Clone, patch, and install dwm
    install_dwm
}

# Run the main function
main

