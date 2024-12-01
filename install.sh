#!/bin/bash

# Major Components
install_dependencies() {
    # Install dependencies using pacman
    sudo pacman -S --noconfirm xorg-server libx11 libxft libxinerama gcc make \
                 python libxkbcommon fontconfig libxcb neovim python-pynvim \
                 lua libtermkey libvterm unibilium tree-sitter cmake ninja pkgconf \
                 picom libconfig libev libgl libepoxy pcre2 pixman xcb-util-image \
                 xcb-util-renderutil dbus xorg-xprop xorg-xwininfo rtkit meson git \
                 xorgproto libxext

    # Install dependencies using yay
    yay -S --noconfirm msgpack
}

install_fonts() {
    # Install Nerd Fonts (Fira, Hack, JetBrains Mono)
    yay -S --noconfirm ttf-fira-code ttf-hack ttf-jetbrains-mono

    # Install icons and symbols
    yay -S --noconfirm nerd-fonts-symbols nerd-fonts-glyphs
}

clone_and_patch_dwm() {
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

    # Remove the existing config.def.h file and copy custom config.def.h
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

install_zsh() {
    # Check if Zsh is installed
    if ! command -v zsh &>/dev/null; then
        echo "Zsh not found, installing..."
        sudo pacman -S --noconfirm zsh
    else
        echo "Zsh is already installed."
    fi

    # Install Oh My Zsh if not already installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "Oh My Zsh is already installed."
    fi

    # Set Zsh as the default shell
    chsh -s $(which zsh)
    echo "Zsh set as the default shell."
}

clone_zsh_plugins() {
    # Clone Zsh plugins (autosuggestions and syntax highlighting)
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting"

    echo "Cloned Zsh plugins."
}

copy_zsh_config() {
    # Copy the custom .zshrc file
    CONFIG_ZSHRC="$HOME/dot_files/.config/zsh/.zshrc"
    if [ -f "$CONFIG_ZSHRC" ]; then
        cp "$CONFIG_ZSHRC" "$HOME/.zshrc"
        echo "Copied custom .zshrc to the home directory."
    else
        echo "Custom .zshrc file not found."
        exit 1
    fi
}

install_oh_my_posh() {
    # Install Oh My Posh if needed
    if [ ! -d "$HOME/.config/oh-my-posh" ]; then
        echo "Cloning and installing Oh My Posh..."
        git clone https://github.com/JanDeDobbeleer/oh-my-posh.git "$HOME/.config/oh-my-posh"
    else
        echo "Oh My Posh is already installed."
    fi
}

copy_xinitrc() {
    # Copy the .xinitrc file
    XINITRC="$HOME/dot_files/.config/.xinitrc"
    if [ -f "$XINITRC" ]; then
        cp "$XINITRC" "$HOME/.xinitrc"
        echo "Copied custom .xinitrc to the home directory."
    else
        echo ".xinitrc file not found."
        exit 1
    fi
}

copy_kitty_and_nvim() {
    # Copy Kitty and Neovim configuration folders
    if [ -d "$HOME/dot_files/.config/kitty" ]; then
        cp -r "$HOME/dot_files/.config/kitty" "$HOME/.config/"
        echo "Copied Kitty configuration."
    else
        echo "Kitty configuration not found."
    fi

    if [ -d "$HOME/dot_files/.config/nvim" ]; then
        cp -r "$HOME/dot_files/.config/nvim" "$HOME/.config/"
        echo "Copied Neovim configuration."
    else
        echo "Neovim configuration not found."
    fi
}

# Main Function
main() {
    # Install dependencies
    install_dependencies

    # Install fonts
    install_fonts

    # Clone and patch DWM
    clone_and_patch_dwm

    # Install Zsh and set it as default
    install_zsh

    # Clone Zsh plugins
    clone_zsh_plugins

    # Copy .zshrc file
    copy_zsh_config

    # Install Oh My Posh
    install_oh_my_posh

    # Copy .xinitrc file
    copy_xinitrc

    # Copy Kitty and Neovim folders
    copy_kitty_and_nvim
}

# Run the main function
main

