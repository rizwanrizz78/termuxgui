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
pkg install -y xfce4 xfce4-goodies termux-x11-nightly proot-distro

# Install Default Theme/Wallpaper
log_info "Applying Default Theme and Wallpaper..."
# Copy theme files (assuming placeholders exist)
mkdir -p ~/.themes ~/.icons
cp -r themes/default ~/.themes/ || log_warning "Default theme not found, skipping."
# Set wallpaper (assuming xfconf-query is available after xfce install)
# This might fail if xfconfd isn't running, so we'll just copy the file.
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml/
cp configs/xfce4-desktop.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/ || log_warning "XFCE config not found."

# Install Essential Apps
log_info "Installing Essential Apps Bundle..."
pkg install -y firefox vlc git python nodejs

# Enable Performance Optimizations
log_info "Enabling Performance Mode..."
enable_performance_mode

# Install App Store Dependencies
log_info "Installing App Store Dependencies..."
pkg install -y python-tkinter

# Setup App Store Shortcut
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

# Install TermiDesk Startup Script
log_info "Installing Startup Script..."
cp scripts/start-termidesk.sh $PREFIX/bin/termidesk
chmod +x $PREFIX/bin/termidesk

log_success "Recommended Installation Complete!"
log_info "You can start the desktop by running: termidesk"
