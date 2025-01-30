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
		neovim kitty nodejs npm dmenu xclip 

	yay -S --noconfirm uthash
	echo "Dependencies installed successfully."
}

install_dwm() {
  # Update system
  echo "Updating system..."
  sudo pacman -Syu --noconfirm

  # Install dependencies
  echo "Installing dependencies..."
  sudo pacman -S --noconfirm base-devel git

  # Clone dwm repository
  echo "Cloning dwm repository..."
  git clone https://git.suckless.org/dwm

  # Navigate into the dwm directory
  cd dwm || { echo "Failed to enter dwm directory."; return 1; }

  # Build and install dwm
  echo "Building dwm..."
  sudo make clean install

  # Check if installation is successful
  if which dwm >/dev/null 2>&1; then
    echo "dwm installed successfully!"
  else
    echo "Installation failed."
    return 1
  fi

  # Optionally, copy the configuration file
  echo "Setting up configuration file..."
  cp config.h ~/.dwm_config.h

  echo "Installation complete! You can now run dwm with the 'dwm' command."
}


# Function to install nerd fonts
install_nerd_fonts() {
    echo "Installing nerd fonts (Fira, Hack, JetBrains)..."
    yay -S --noconfirm nerd-fonts-fira nerd-fonts-hack nerd-fonts-jetbrains-mono
    echo "Nerd fonts installed."
}

# Call the function to check and install yay if needed
main() {
	install_yay_if_needed
	install_dependencies
	install_nerd_fonts	
	install_dwm
}

main
