#!/bin/bash

# TermiDesk One-Click Installer
# This script bootstraps the installation process.

echo "========================================"
echo "    Starting TermiDesk Installer...     "
echo "========================================"

# 1. Update Packages Non-Interactively
echo "[*] Updating repositories..."
pkg update -y -o Dpkg::Options::="--force-confnew" || { echo "Update failed! Check your internet connection."; exit 1; }
pkg upgrade -y -o Dpkg::Options::="--force-confnew"

# 2. Install Git
echo "[*] Installing dependencies..."
pkg install -y git -o Dpkg::Options::="--force-confnew"

# 3. Clone Repository
REPO_DIR="$HOME/TermiDesk"
if [ -d "$REPO_DIR" ]; then
    echo "[*] Updating existing TermiDesk repository..."
    cd "$REPO_DIR" && git pull
else
    echo "[*] Cloning TermiDesk..."
    git clone https://github.com/rizwanrizz78/termuxgui.git "$REPO_DIR"
fi

# 4. Run Recommended Installer
echo "[*] Launching Installer..."
cd "$REPO_DIR"
chmod +x install.sh recommended.sh manual-installer.sh gpu/detection.sh scripts/*.sh
bash install.sh --recommended

echo "========================================"
echo "    Setup Complete! Type 'termidesk'    "
echo "========================================"
