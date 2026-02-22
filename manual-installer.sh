#!/bin/bash

# Source helper functions and detection
source ./utils.sh
source ./gpu/detection.sh
source ./scripts/performance.sh

log_info "Starting Manual Installation..."

# GPU Detection
detect_gpu_result=$(detect_gpu)
eval "$detect_gpu_result"

# Confirm GPU
if whiptail --title "GPU Configuration" --yesno "Detected GPU: $VENDOR ($MODEL)\nRecommended Driver: $DRIVER\n\nDo you want to proceed with this configuration?" 10 60; then
    CHOSEN_DRIVER="$DRIVER"
else
    # Let user choose override
    CHOSEN_DRIVER=$(whiptail --title "Manual GPU Override" --menu "Select GPU Driver:" 15 60 4 \
    "virgl" "Adreno / Qualcomm (Hardware Accel)" \
    "panfrost" "Mali / Exynos / MediaTek (Hardware Accel)" \
    "llvmpipe" "Software Rendering (Safe Fallback)" \
    "none" "Skip GPU Setup" 3>&1 1>&2 2>&3)
fi

configure_gpu "$CHOSEN_DRIVER"

# Component Selection
COMPONENTS=$(whiptail --title "TermiDesk Components" --checklist \
"Select components to install:" 20 78 10 \
"DESKTOP" "XFCE4 Desktop Environment" ON \
"BROWSERS" "Firefox & Chromium" OFF \
"MEDIA" "VLC & MPV" OFF \
"DEV" "Developer Tools (Git, Python, Node)" OFF \
"UTILS" "Utilities (Htop, Neofetch)" OFF \
"THEMES" "Additional Themes" OFF \
"WALLPAPERS" "Additional Wallpapers" OFF \
"PERFORMANCE" "Enable Performance Mode" OFF \
"APPSTORE" "TermiDesk App Store" ON 3>&1 1>&2 2>&3)

# Process Selection
# Remove quotes from the selection string
COMPONENTS="${COMPONENTS//\"/}"

for COMPONENT in $COMPONENTS; do
    case $COMPONENT in
        DESKTOP)
            log_info "Installing XFCE4..."
            pkg install -y xfce4 xfce4-goodies termux-x11-nightly proot-distro
            ;;
        BROWSERS)
            log_info "Installing Browsers..."
            pkg install -y firefox chromium
            ;;
        MEDIA)
            log_info "Installing Media Apps..."
            pkg install -y vlc mpv ffmpeg
            ;;
        DEV)
            log_info "Installing Developer Tools..."
            pkg install -y git python nodejs neovim
            ;;
        UTILS)
            log_info "Installing Utilities..."
            pkg install -y htop neofetch ranger
            ;;
        THEMES)
            log_info "Installing Themes..."
            # Copy all themes
            mkdir -p ~/.themes
            cp -r themes/* ~/.themes/ 2>/dev/null
            ;;
        WALLPAPERS)
            log_info "Installing Wallpapers..."
            # Copy all wallpapers
            mkdir -p ~/.wallpapers
            cp -r wallpapers/* ~/.wallpapers/ 2>/dev/null
            ;;
        PERFORMANCE)
            log_info "Enabling Performance Mode..."
            enable_performance_mode
            ;;
        APPSTORE)
            log_info "Installing App Store..."
            pkg install -y python-tkinter
            mkdir -p ~/Desktop
            echo "[Desktop Entry]
Version=1.0
Type=Application
Name=TermiDesk App Store
Comment=Install and Manage Apps
Exec=python $PWD/appstore/appstore.py
Icon=utilities-terminal
Path=$PWD/appstore
Terminal=false
StartupNotify=false" > ~/Desktop/appstore.desktop
            chmod +x ~/Desktop/appstore.desktop
            ;;
    esac
done

log_success "Manual Installation Complete!"
