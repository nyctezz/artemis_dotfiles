#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Ensure config folder exists
mkdir -p "$HOME/.config"

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "-=<REPACKING ARTEMIS DOTFILES>=-"

echo
echo "Linking dotfiles:"

for folder in "$REPO_DIR"/.config/*; do
    if [ -d "$folder" ]; then
        folder_name=$(basename "$folder")

        if rm -rf "$HOME/.config/$folder_name" &&
           ln -s "$folder" "$HOME/.config/$folder_name"; then
            echo -e "${GREEN}✔${NC} Linked ~/.config/$folder_name"
        else
            echo -e "${RED}✘${NC} Failed to link ~/.config/$folder_name"
        fi
    fi
done

echo
echo "Package install:"

prompt_and_install() {
    local file_path=$1
    local install_cmd=$2
    local label=$3

    if [ ! -f "$file_path" ]; then
        echo -e "${YELLOW}!${NC} No $label package list found at $file_path, skipping."
        return
    fi

    mapfile -t packages < "$file_path"

    if [ ${#packages[@]} -eq 0 ]; then
        echo -e "${YELLOW}!${NC} No packages listed in $file_path."
        return
    fi

    echo
    echo "Found ${#packages[@]} $label packages."

    for pkg in "${packages[@]}"; do
        # Skip blank lines and comments
        [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue

        read -p "Install package '$pkg'? [Y/n] " -n 1 -r
        echo

        if [[ $REPLY =~ ^[Nn]$ ]]; then
            echo -e "${YELLOW}↷${NC} Skipped $pkg"
            continue
        fi

        echo "Installing $pkg..."

        if $install_cmd "$pkg"; then
            echo -e "${GREEN}✔${NC} Installed $pkg"
        else
            echo -e "${RED}✘${NC} Failed to install $pkg"
        fi
    done
}

# Official packages
prompt_and_install \
    "$REPO_DIR/.config/packages.txt" \
    "sudo pacman -S --needed --noconfirm" \
    "Official Pacman"

# AUR packages
if command -v yay >/dev/null 2>&1; then
    prompt_and_install \
        "$REPO_DIR/.config/aur_packages.txt" \
        "yay -S --needed --noconfirm" \
        "AUR"
elif command -v paru >/dev/null 2>&1; then
    prompt_and_install \
        "$REPO_DIR/.config/aur_packages.txt" \
        "paru -S --needed --noconfirm" \
        "AUR"
else
    echo
    echo -e "${YELLOW}!${NC} No AUR helper (yay/paru) detected. Skipping AUR packages."
fi

echo
echo -e "${GREEN}=-=-= Repacking finished successfully. =-=-=${NC}"
