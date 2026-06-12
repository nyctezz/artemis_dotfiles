#!/bin/bash

# Ensure config folder exists
mkdir -p ~/.config
REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "=========================================="
echo "      STEP 1: Linking Dotfiles            "
echo "=========================================="
for folder in "$REPO_DIR"/.config/*; do
    if [ -d "$folder" ]; then
        folder_name=$(basename "$folder")
        rm -rf "$HOME/.config/$folder_name"
        ln -s "$folder" "$HOME/.config/$folder_name"
        echo "Linked ~/.config/$folder_name"
    fi
done

echo -e "\n=========================================="
echo "      STEP 2: Interactive Package Install "
echo "=========================================="

# Function to handle interactive prompting
prompt_and_install() {
    local file_path=$1
    local install_cmd=$2
    local label=$3

    if [ ! -f "$file_path" ]; then
        echo "No $label package list found at $file_path, skipping."
        return
    fi

    # Read packages into an array
    mapfile -t packages < "$file_path"

    if [ ${#packages[@]} -eq 0 ]; then
        echo "No packages listed in $file_path."
        return
    fi

    echo -e "\nFound ${#packages[@]} $label packages to potentially install."
    
    # Loop over individual packages
    for pkg in "${packages[@]}"; do
        # Default option is Yes [Y/n]
        read -p "Install package '$pkg'? [Y/n] " -n 1 -r
        echo # Move to a new line
        
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            echo "Skipping $pkg..."
        else
            echo "Installing $pkg..."
            # Execute the provided installation command (e.g. sudo pacman -S --needed)
            $install_cmd "$pkg"
        fi
    done
}

# Run the prompt for Official Arch Packages
prompt_and_install "$REPO_DIR/.config/packages.txt" "sudo pacman -S --needed --noconfirm" "Official Pacman"

# Check if an AUR helper like yay exists before trying to prompt for AUR packages
if command -v yay &> /dev/null; then
    prompt_and_install "$REPO_DIR/.config/aur_packages.txt" "yay -S --needed --noconfirm" "AUR"
elif command -v paru &> /dev/null; then
    prompt_and_install "$REPO_DIR/.config/aur_packages.txt" "paru -S --needed --noconfirm" "AUR"
else
    echo -e "\n[!] No AUR helper (yay/paru) detected. Skipping your AUR package list."
fi

echo -e "\n✨ All choices processed! System template loaded perfectly."
