#!/bin/bash

# Function to check if yay is installed, and install it if it's not
install_yay_if_needed() {
	# Check if yay is installed
	if command -v yay &>/dev/null; then
		echo "yay is already installed."
	else
		echo "yay is not installed. Installing yay..."

		# Update system
		echo "Updating system..."
		sudo pacman -Syu --noconfirm

		# Install necessary dependencies
		echo "Installing dependencies..."
		sudo pacman -S --needed --noconfirm git base-devel

		# Clone the yay repository
		echo "Cloning yay repository from AUR..."
		git clone https://aur.archlinux.org/yay.git

		# Navigate to the yay directory
		cd yay

		# Build and install yay
		echo "Building and installing yay..."
		makepkg -si --noconfirm

		# Clean up the yay directory
		cd ..
		rm -rf yay

		# Verify installation
		if command -v yay &>/dev/null; then
			echo "yay installed successfully!"
		else
			echo "yay installation failed."
		fi
	fi
}

install_dependencies() {
	echo "Installing required dependencies..."
	sudo pacman -S --noconfirm xorg-server libx11 libxft libxinerama gcc make \
		python libxkbcommon fontconfig libxcb neovim python-pynvim lua libtermkey \
		libvterm unibilium tree-sitter cmake ninja pkgconf picom libconfig libev \
		libgl libepoxy pcre2 pixman xcb-util-image xcb-util-renderutil dbus \
		xorg-xprop xorg-xwininfo rtkit meson git xorgproto libxext asciidoc \
		neovim kitty nodejs npm dmenu xclip bat eza bluez-utils bluez  pulseaudio-bluetooth \
  		zsh wget

	yay -S --noconfirm uthash
	echo "Dependencies installed successfully."
}

install_dwm() {
echo "Cloning dwm repository..."
    DWM_REPO="https://git.suckless.org/dwm"
    DWM_DIR="$HOME/dwm"
    PATCH_FOLDER="$HOME/dot_Files/.config/dwm/patches"
    CONFIG_H="$HOME/dot_Files/.config/dwm/config.h"

    # Clone dwm repository into the home directory
    if [ -d "$DWM_DIR" ]; then
        echo "dwm directory already exists. Skipping clone."
    else
        git clone "$DWM_REPO" "$DWM_DIR" && echo "Cloned dwm repository."
    fi

    # Copy patch folder and config.h to the dwm directory
    if [ -d "$PATCH_FOLDER" ]; then
        cp -r "$PATCH_FOLDER" "$DWM_DIR/patches" && echo "Copied patches folder into dwm directory."
    else
        echo "Patch folder not found at $PATCH_FOLDER. Exiting..."
        exit 1
    fi

    if [ -f "$CONFIG_H" ]; then
        cp "$CONFIG_H" "$DWM_DIR/config.h" && echo "Copied custom config.h to dwm directory."
    else
        echo "Custom config.h file not found at $CONFIG_H. Exiting..."
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

    # Build and install dwm
    cd "$DWM_DIR" || exit
    sudo make clean install && echo "dwm has been successfully built and installed."
}


# Function to install nerd fonts
install_nerd_fonts() {
    echo "Installing nerd fonts (Fira, Hack, JetBrains)..."
    yay -S --noconfirm nerd-fonts-fira nerd-fonts-hack nerd-fonts-jetbrains-mono
    echo "Nerd fonts installed."
}

install_picom() {
  cd ~
  # Clone the picom repository from GitHub
  echo "Cloning picom repository..."
  git clone --recursive https://github.com/EdenQwQ/picom.git

  # Navigate into the picom directory
  cd picom || { echo "Failed to enter picom directory."; return 1; }

  # Initialize submodules (if any)
  echo "Initializing submodules..."
  git submodule update --init --recursive

  # Set up Meson build system
  echo "Setting up build with Meson..."
  meson --buildtype=release . build

  # Build picom using Ninja
  echo "Building picom..."
  ninja -C build

  # Install picom
  echo "Installing picom..."
  sudo ninja -C build install

  # Verify installation
  if which picom >/dev/null 2>&1; then
    echo "picom installed successfully!"
  else
    echo "Installation failed."
    return 1
  fi

  echo "Installation complete! You can now run picom with the 'picom' command."
}

# Call the function to check and install yay if needed
main() {
	install_yay_if_needed
	install_dependencies
	install_nerd_fonts	
	install_dwm
	install_picom
}

main
