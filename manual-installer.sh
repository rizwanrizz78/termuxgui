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
            run_pkg_install xfce4 xfce4-goodies termux-x11-nightly proot-distro starship neofetch x11-repo xfce4-pulseaudio-plugin xfce4-battery-plugin xfce4-whiskermenu-plugin kvantum rofi

            # Download Pro Themes & Icons (Nordic & Qogir)
            log_info "Downloading Professional Themes..."
            mkdir -p ~/.themes ~/.icons ~/.fonts ~/.wallpapers

            # Theme (Nordic)
            curl -sL "https://raw.githubusercontent.com/sabamdarif/termux-desktop/setup-files/setup-files/xfce/look_1/theme.tar.gz" -o theme.tar.gz
            tar -xzf theme.tar.gz -C ~/.themes/
            rm theme.tar.gz

            # Icons (Qogir)
            curl -sL "https://raw.githubusercontent.com/sabamdarif/termux-desktop/setup-files/setup-files/xfce/look_1/icon.tar.gz" -o icon.tar.gz
            tar -xzf icon.tar.gz -C ~/.icons/
            rm icon.tar.gz

            # Wallpapers
            curl -sL "https://raw.githubusercontent.com/sabamdarif/termux-desktop/setup-files/setup-files/xfce/look_1/wallpaper.tar.gz" -o wallpaper.tar.gz
            tar -xzf wallpaper.tar.gz -C ~/.wallpapers/
            cp ~/.wallpapers/* ~/.wallpapers/default.jpg 2>/dev/null || true
            rm wallpaper.tar.gz

            # Fonts (0xProto Nerd Font)
            log_info "Installing Nerd Fonts..."
            curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/0xProto.tar.xz" -o font.tar.xz
            tar -xf font.tar.xz -C ~/.fonts/
            rm font.tar.xz
            fc-cache -f

            # Configure Shell Aesthetics
            if ! grep -q "source $PWD/configs/setup-shell.sh" ~/.bashrc; then
                echo "source $PWD/configs/setup-shell.sh" >> ~/.bashrc
            fi
            # Apply Custom Theme Configuration (Terminal)
            mkdir -p ~/.config/xfce4/terminal/
            cp configs/terminalrc ~/.config/xfce4/terminal/terminalrc 2>/dev/null || true

            # Apply XFCE Desktop Settings (Force Theme)
            log_info "Forcing XFCE Theme Settings..."
            pkill xfconfd >/dev/null 2>&1 || true
            XFCONF_DIR="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
            mkdir -p "$XFCONF_DIR"
            cp -f configs/xfconf/*.xml "$XFCONF_DIR/" || log_warning "Could not copy XFCE configs."

            # Apply Termux App Styling
            log_info "Styling Termux App..."
            mkdir -p ~/.termux
            cp configs/termux/*.properties ~/.termux/ 2>/dev/null || true
            am broadcast --user 0 -a com.termux.app.reload_style com.termux >/dev/null 2>&1 || true
            ;;
        BROWSERS)
            log_info "Installing Browsers..."
            run_pkg_install firefox chromium
            ;;
        MEDIA)
            log_info "Installing Media Apps..."
            run_pkg_install vlc mpv ffmpeg
            ;;
        DEV)
            log_info "Installing Developer Tools..."
            run_pkg_install git python nodejs neovim
            ;;
        UTILS)
            log_info "Installing Utilities..."
            run_pkg_install htop neofetch ranger
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
            run_pkg_install python-tkinter python-pillow
            mkdir -p ~/Desktop
            echo "[Desktop Entry]
Version=1.0
Type=Application
Name=TermiDesk App Store
Comment=Install and Manage Apps
Exec=python $PWD/appstore/appstore.py
Icon=system-software-install
Path=$PWD/appstore
Terminal=false
StartupNotify=false" > ~/Desktop/appstore.desktop
            chmod +x ~/Desktop/appstore.desktop
            ;;
    esac
done

# Install TermiDesk Startup Script
log_info "Installing Startup Script..."
cp scripts/start-termidesk.sh $PREFIX/bin/termidesk
chmod +x $PREFIX/bin/termidesk

log_success "Manual Installation Complete!"
log_info "You can start the desktop by running: termidesk"
