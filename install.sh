#!/usr/bin/bash

# Install packages
echo "========== Installing Packages =========="

echo "========== Packages Installed =========="

# Create symlinks
echo "========== Creating Symlinks =========="

mkdir -p "$HOME/.config"
ln -sfn "$HOME/.dotfiles/hypr" "$HOME/.config/hypr"
ln -sfn "$HOME/.dotfiles/nvim" "$HOME/.config/nvim"
ln -sfn "$HOME/.dotfiles/waybar" "$HOME/.config/waybar"

echo "========== Symlinks Created =========="
