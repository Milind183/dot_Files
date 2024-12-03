#!/bin/bash

# Function to check if yay is installed
check_yay() {
    echo "Checking if yay is installed..."
    if ! command -v yay &> /dev/null; then
        echo "yay not found, installing yay..."
        sudo pacman -S --noconfirm yay
    else
        echo "yay is already installed."
    fi
}

# Function to install required dependencies
install_dependencies() {
    echo "Installing required dependencies..."
    sudo pacman -S --noconfirm xorg-server libx11 libxft libxinerama gcc make \
        python libxkbcommon fontconfig libxcb neovim python-pynvim lua libtermkey \
        libvterm unibilium tree-sitter cmake ninja pkgconf picom libconfig libev \
        libgl libepoxy pcre2 pixman xcb-util-image xcb-util-renderutil dbus \
        xorg-xprop xorg-xwininfo rtkit meson git xorgproto libxext

    yay -S --noconfirm msgpack
    echo "Dependencies installed successfully."
}

# Function to install nerd fonts
install_nerd_fonts() {
    echo "Installing nerd fonts (Fira, Hack, JetBrains)..."
    yay -S --noconfirm nerd-fonts-fira nerd-fonts-hack nerd-fonts-jetbrains-mono
    echo "Nerd fonts installed."
}

# Function to clone dwm repository and apply patches
clone_and_patch_dwm() {
    echo "Cloning dwm repository..."
    DWM_REPO="https://git.suckless.org/dwm"
    DWM_DIR="$HOME/dwm"
    PATCH_FOLDER="$HOME/dot_files/.config/dwm/patches"
    CONFIG_H="$HOME/dot_files/.config/dwm/config.def.h"

    if [ -d "$DWM_DIR" ]; then
        echo "dwm directory already exists. Skipping clone."
    else
        git clone "$DWM_REPO" "$DWM_DIR" && echo "Cloned dwm repository."
    fi

    # Copy patch folder to dwm
    if [ -d "$PATCH_FOLDER" ]; then
        cp -r "$PATCH_FOLDER" "$DWM_DIR/patches" && echo "Copied patches folder into dwm directory."
    else
        echo "Patch folder not found at $PATCH_FOLDER. Exiting..."
        exit 1
    fi

    # Apply patches
    for PATCH in "$DWM_DIR/patches"/*.diff; do
        if [ -f "$PATCH" ]; then
            cd "$DWM_DIR" || exit
            patch -p1 < "$PATCH" && echo "Applied patch: $PATCH"
        else
            echo "Patch file $PATCH not found. Skipping..."
        fi
    done

    # Replace config.def.h with custom config
    if [ -f "$CONFIG_H" ]; then
        rm -f "$DWM_DIR/config.def.h" && echo "Removed old config.def.h."
        cp "$CONFIG_H" "$DWM_DIR/config.def.h" && echo "Copied custom config.def.h to dwm directory."
    else
        echo "Custom config.def.h file not found at $CONFIG_H. Exiting..."
        exit 1
    fi

    # Build and install dwm
    cd "$DWM_DIR" || exit
    sudo make clean install && echo "dwm has been successfully built and installed."
}

# Function to install and configure zsh with oh-my-zsh
install_zsh() {
    echo "Installing Zsh..."
    sudo pacman -S --noconfirm zsh

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Cloning oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "oh-my-zsh already installed, skipping installation."
    fi

    # Clone plugins for Zsh
    echo "Cloning Zsh plugins..."
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
        ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting

    # Copy the .zshrc file
    ZSHRC_FILE="$HOME/dot_files/.config/zsh/.zshrc"
    if [ -f "$ZSHRC_FILE" ]; then
        cp "$ZSHRC_FILE" "$HOME/.zshrc" && echo "Copied .zshrc file."
    else
        echo ".zshrc file not found at $ZSHRC_FILE. Exiting..."
        exit 1
    fi

    # Set zsh as the default shell
    chsh -s $(which zsh) && echo "Zsh set as the default shell."
}

# Function to install oh-my-posh
install_oh_posh() {
    echo "Cloning and installing oh-my-posh..."
    git clone https://github.com/JanDeDobbeleer/oh-my-posh.git "$HOME/.config/oh-my-posh"
    cd "$HOME/.config/oh-my-posh"
    sudo make install && echo "oh-my-posh installed."
}

# Function to copy .xinitrc file
copy_xinitrc() {
    XINITRC_FILE="$HOME/dot_files/.config/xinitrc"
    if [ -f "$XINITRC_FILE" ]; then
        cp "$XINITRC_FILE" "$HOME/.xinitrc" && echo "Copied .xinitrc file."
    else
        echo ".xinitrc file not found at $XINITRC_FILE. Exiting..."
        exit 1
    fi
}

# Function to copy kitty and nvim folders
copy_kitty_nvim() {
    # Copy the kitty config folder
    KITTY_CONFIG_DIR="$HOME/dot_files/.config/kitty"
    if [ -d "$KITTY_CONFIG_DIR" ]; then
        cp -r "$KITTY_CONFIG_DIR" "$HOME/.config/kitty" && echo "Copied kitty config."
    else
        echo "Kitty config folder not found at $KITTY_CONFIG_DIR. Skipping..."
    fi

    # Copy the nvim config folder
    NVIM_CONFIG_DIR="$HOME/dot_files/.config/nvim"
    if [ -d "$NVIM_CONFIG_DIR" ]; then
        cp -r "$NVIM_CONFIG_DIR" "$HOME/.config/nvim" && echo "Copied nvim config."
    else
        echo "Nvim config folder not found at $NVIM_CONFIG_DIR. Skipping..."
    fi
}

# Main function to execute all steps in order
main() {
    echo "Starting setup..."

    check_yay
    install_dependencies
    install_nerd_fonts
    clone_and_patch_dwm
    install_zsh
    install_oh_posh
    copy_xinitrc
    copy_kitty_nvim

    echo "Setup completed successfully."
}

# Run the main function
main

