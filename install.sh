#!/bin/bash

# Source helper functions
if [ -f "./utils.sh" ]; then
    source ./utils.sh
else
    echo "Error: utils.sh not found."
    exit 1
fi

# Bootstrap Dependencies
echo "Bootstrapping dependencies..."
pkg update -y
pkg install -y git wget curl whiptail x11-repo tur-repo

# Function to show usage
show_usage() {
    echo "Usage: bash install.sh [OPTION]"
    echo "Options:"
    echo "  --recommended   Install with recommended settings (Auto-detect GPU, XFCE4, essential apps)"
    echo "  --manual        Interactive installation menu"
    echo "  --help          Show this help message"
}

# Parse Arguments
MODE="manual" # Default to manual if no args? Or show help? Let's show help if unknown.

if [[ "$#" -eq 0 ]]; then
    # If no arguments, we can default to manual or show a menu.
    # Let's show a simple dialog to choose.
    if whiptail --title "TermiDesk Installer" --yesno "Welcome to TermiDesk Installer!\n\nDo you want to proceed with the Recommended installation?" 10 60; then
        MODE="recommended"
    else
        MODE="manual"
    fi
else
    case "$1" in
        --recommended)
            MODE="recommended"
            ;;
        --manual)
            MODE="manual"
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
fi

# Execute based on mode
if [[ "$MODE" == "recommended" ]]; then
    log_info "Starting Recommended Installation..."
    bash recommended.sh
elif [[ "$MODE" == "manual" ]]; then
    log_info "Starting Manual Installation..."
    bash manual-installer.sh
fi
