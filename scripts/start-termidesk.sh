#!/bin/bash

# TermiDesk Startup Script

# 1. Cleanup
echo "Cleaning up previous sessions..."
pkill -f com.termux.x11
pkill -f xfce4-session
pkill -f virgl_test_server

# 2. Start Termux:X11
echo "Starting Termux:X11..."
termux-x11 :0 >/dev/null 2>&1 &

# Wait for X server to initialize
sleep 3

# 3. Set Display
export DISPLAY=:0

# 4. GPU Handling (Check detection result or config)
# We can source the detection script again or check a config file.
# Since we didn't save the config, let's re-detect for now or check for specific packages.
# A robust way would be to check if 'virglrenderer-android' is installed and we are on Adreno.

if command -v virgl_test_server_android &> /dev/null; then
    # Check if we should use it (e.g. if we are on Adreno)
    # Re-using detection logic briefly:
    if command -v glxinfo &> /dev/null; then
        renderer=$(glxinfo -B 2>/dev/null | grep "OpenGL renderer")
        if [[ "$renderer" == *"Adreno"* ]]; then
            echo "Starting VirGL Server..."
            virgl_test_server_android &
            export MESA_LOADER_DRIVER_OVERRIDE=zink
            export GALLIUM_DRIVER=zink
        fi
    fi
fi

# 5. Start XFCE4
echo "Starting XFCE4 Desktop..."
dbus-launch --exit-with-session xfce4-session &

echo "Desktop started! If you see a black screen, switch to the Termux:X11 app."
