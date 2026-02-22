#!/bin/bash

# Source helper functions and detection
source ./utils.sh
source ./gpu/detection.sh
source ./scripts/performance.sh

log_info "Starting Recommended Installation..."

# GPU Detection
detect_gpu_result=$(detect_gpu)
eval "$detect_gpu_result"

log_info "Detected GPU Vendor: $VENDOR"
log_info "Recommended Driver: $DRIVER"

# Auto-configure GPU
configure_gpu "$DRIVER"

# Core Desktop Installation
log_info "Installing XFCE4 Desktop Environment..."
run_pkg_install xfce4 xfce4-goodies termux-x11-nightly proot-distro

# Install Enhanced UI Components (Themes, Icons, Shell)
log_info "Installing Enhanced UI Components..."
run_pkg_install starship neofetch x11-repo xfce4-pulseaudio-plugin xfce4-battery-plugin xfce4-whiskermenu-plugin xfce4-clipman-plugin kvantum rofi || log_warning "Could not install some UI components."

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
# Ensure default exists
cp ~/.wallpapers/* ~/.wallpapers/default.jpg 2>/dev/null || true
rm wallpaper.tar.gz

# Fonts (0xProto Nerd Font)
log_info "Installing Nerd Fonts..."
curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/0xProto.tar.xz" -o font.tar.xz
tar -xf font.tar.xz -C ~/.fonts/
rm font.tar.xz
fc-cache -f

# Apply Custom Theme Configuration
log_info "Applying Custom Theme Configuration..."
mkdir -p ~/.config/xfce4/terminal/
cp configs/terminalrc ~/.config/xfce4/terminal/terminalrc 2>/dev/null || true

# Apply XFCE Desktop Settings (Force Theme)
log_info "Forcing XFCE Theme Settings..."
# Kill xfconfd to ensure new configs are picked up
pkill xfconfd >/dev/null 2>&1 || true
XFCONF_DIR="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
mkdir -p "$XFCONF_DIR"
cp -f configs/xfconf/*.xml "$XFCONF_DIR/" || log_warning "Could not copy XFCE configs."

# Apply Termux App Styling
log_info "Styling Termux App..."
mkdir -p ~/.termux
cp configs/termux/*.properties ~/.termux/ 2>/dev/null || true
# Reload Termux settings if possible
am broadcast --user 0 -a com.termux.app.reload_style com.termux >/dev/null 2>&1 || true

# Configure Shell Aesthetics
log_info "Configuring Shell Aesthetics..."
if ! grep -q "source $PWD/configs/setup-shell.sh" ~/.bashrc; then
    echo "source $PWD/configs/setup-shell.sh" >> ~/.bashrc
fi

# Install Essential Apps
log_info "Installing Essential Apps Bundle..."
run_pkg_install firefox vlc git python nodejs

# Enable Performance Optimizations
log_info "Enabling Performance Mode..."
enable_performance_mode

# Install App Store Dependencies
log_info "Installing App Store Dependencies..."
run_pkg_install python-tkinter python-pillow

# Setup App Store Shortcut
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

# Install TermiDesk Startup Script
log_info "Installing Startup Script..."
cp scripts/start-termidesk.sh $PREFIX/bin/termidesk
chmod +x $PREFIX/bin/termidesk

log_success "Recommended Installation Complete!"
log_info "You can start the desktop by running: termidesk"
