#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Ensure config folder exists
mkdir -p "$HOME/.config"

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
BACKUP_CREATED=false

echo "-=<REPACKING ARTEMIS DOTFILES>=-"

echo
echo "Linking dotfiles:"

for folder in "$REPO_DIR"/.config/*; do
    if [ -d "$folder" ]; then
        folder_name=$(basename "$folder")
        target="$HOME/.config/$folder_name"

        # Back up existing config if it exists and isn't already the correct symlink
        if [ -e "$target" ] || [ -L "$target" ]; then
            if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$(readlink -f "$folder")" ]; then
                :
            else
                if [ "$BACKUP_CREATED" = false ]; then
                    mkdir -p "$BACKUP_DIR"
                    BACKUP_CREATED=true
                fi

                mv "$target" "$BACKUP_DIR/$folder_name"

                echo -e "${YELLOW}↷${NC} Backed up ~/.config/$folder_name"
            fi
        fi

        if ln -sfn "$folder" "$target"; then
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

install_aur_packages() {
    local aur_helper=""
    local aur_cmd=""

    # Detect existing helper
    if command -v paru >/dev/null 2>&1; then
        aur_helper="paru"
        aur_cmd="paru -S --needed --noconfirm"
    elif command -v yay >/dev/null 2>&1; then
        aur_helper="yay"
        aur_cmd="yay -S --needed --noconfirm"
    else
        echo
        echo -e "${YELLOW}!${NC} No AUR helper detected."
        echo
        echo "Select an AUR helper to install:"
        echo "  1) paru (recommended)"
        echo "  2) yay"
        echo "  3) Skip AUR packages"
        echo

        while true; do
            read -rp "Choice [1-3]: " choice

            case "$choice" in
                1)
                    aur_helper="paru"
                    break
                    ;;
                2)
                    aur_helper="yay"
                    break
                    ;;
                3)
                    echo -e "${YELLOW}↷${NC} Skipping AUR packages."
                    return
                    ;;
                *)
                    echo "Please enter 1, 2, or 3."
                    ;;
            esac
        done

        echo
        echo "Installing prerequisites..."

        if ! sudo pacman -S --needed --noconfirm git base-devel; then
            echo -e "${RED}✘${NC} Failed to install prerequisites."
            return
        fi

        tmpdir=$(mktemp -d)

        echo "Installing $aur_helper..."

        if git clone "https://aur.archlinux.org/${aur_helper}.git" "$tmpdir/$aur_helper" &&
           cd "$tmpdir/$aur_helper" &&
           makepkg -si --noconfirm; then

            echo -e "${GREEN}✔${NC} Installed $aur_helper"

            cd "$REPO_DIR" || return

            aur_cmd="$aur_helper -S --needed --noconfirm"
        else
            echo -e "${RED}✘${NC} Failed to install $aur_helper"
            cd "$REPO_DIR" || true
            rm -rf "$tmpdir"
            return
        fi

        rm -rf "$tmpdir"
    fi

    echo
    echo "Using $aur_helper for AUR packages."

    prompt_and_install \
        "$REPO_DIR/.config/aur_packages.txt" \
        "$aur_cmd" \
        "AUR"
}

# Official packages
prompt_and_install \
    "$REPO_DIR/.config/packages.txt" \
    "sudo pacman -S --needed --noconfirm" \
    "Official Pacman"

# AUR packages
install_aur_packages

echo

if [ "$BACKUP_CREATED" = true ]; then
    echo -e "${YELLOW}ℹ${NC} Existing configuration files were backed up to:"
    echo "    $BACKUP_DIR"
    echo
fi

echo -e "${GREEN}=-=-= Repacking finished successfully. =-=-=${NC}"
