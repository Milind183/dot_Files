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

# Function to install nerd fonts
install_nerd_fonts() {
    echo "Installing nerd fonts (Fira, Hack, JetBrains)..."
    yay -S --noconfirm nerd-fonts-fira nerd-fonts-hack nerd-fonts-jetbrains-mono
    echo "Nerd fonts installed."
}

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


# Call the function to check and install yay if needed
main() {
	install_yay_if_needed
	install_dependencies
}

main
