#!/bin/bash

# Source helper functions
if [ -f "./utils.sh" ]; then
    source ./utils.sh
elif [ -f "../utils.sh" ]; then
    source ../utils.sh
fi

log_info "Configuring XFCE4 Appearance..."

# Check if XFCE is running or we have access to xfconf-query
if command -v xfconf-query &> /dev/null; then
    # Start D-Bus if not running, though this script is usually run during install where X11 might NOT be running.
    # If X11 is not running, xfconf-query might fail or require a specific backend.
    # However, we can try to set properties directly or rely on xfsettingsd to pick them up later if we write to XML.

    # But usually, it's safer to just warn if we can't set it live.
    # We can try to modify the XML config files directly if xfconf-query fails.

    # Try setting Arc-Dark theme
    xfconf-query -c xsettings -p /Net/ThemeName -s "Arc-Dark" || true

    # Try setting Papirus Icons
    xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark" || true

    # Set Font
    xfconf-query -c xsettings -p /Gtk/FontName -s "Monospace 11" || true

    log_success "Theme applied via xfconf-query."
else
    log_warning "xfconf-query not found. Themes will be applied on next login if config files were copied correctly."
fi

# Ensure terminal config is in place (redundant check)
mkdir -p ~/.config/xfce4/terminal/
if [ -f "configs/terminalrc" ]; then
    cp configs/terminalrc ~/.config/xfce4/terminal/terminalrc
    log_success "Terminal color scheme applied."
fi
