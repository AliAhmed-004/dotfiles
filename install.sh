#!/usr/bin/bash

# Install packages
echo "========== Installing Packages =========="
sudo pacman -S --needed - <packages.txt

echo "========== Packages Installed =========="

# Create symlinks
echo "========== Creating Symlinks =========="

mkdir -p "$HOME/.config"
ln -sfn "$HOME/.dotfiles/hypr" "$HOME/.config/hypr"
ln -sfn "$HOME/.dotfiles/nvim" "$HOME/.config/nvim"
ln -sfn "$HOME/.dotfiles/waybar" "$HOME/.config/waybar"
ln -sfn "$HOME/.dotfiles/wallpapers/" "$HOME/.config/wallpapers"
ln -sfn "$HOME/.dotfiles/quickshell" "$HOME/.config/quickshell"

echo "========== Symlinks Created =========="
