#!/bin/bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/Downloads/walls"

# Select a random wallpaper
RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Set the wallpaper using feh
feh --bg-scale "$RANDOM_WALLPAPER"

