#!/bin/bash

# 1. Create the system config directory if it doesn't exist
mkdir -p ~/.config

# 2. Get the absolute path of this script's directory (~/dotfiles)
REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Creating symlinks from $REPO_DIR to ~/.config..."

# 3. Automatically symlink everything inside the repo's .config folder
for folder in "$REPO_DIR"/.config/*; do
    if [ -d "$folder" ]; then
        folder_name=$(basename "$folder")
        
        # Remove existing config folder or broken link if it exists
        rm -rf "$HOME/.config/$folder_name"
        
        # Create the fresh symlink
        ln -s "$folder" "$HOME/.config/$folder_name"
        echo "Linked $folder_name"
    fi
done

echo "✨ System repacked successfully!"
