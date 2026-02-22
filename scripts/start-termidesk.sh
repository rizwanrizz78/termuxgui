#!/bin/bash

# TermiDesk Startup Script (Robust)

# 1. Cleanup
echo "Cleaning up previous sessions..."
pkill -f com.termux.x11
pkill -9 termux-x11
pkill -9 xfce4-session
pkill -9 pulseaudio
pkill -9 virgl_test_server

# 2. Setup Environment
export XDG_RUNTIME_DIR=${PREFIX}/tmp
mkdir -p "$XDG_RUNTIME_DIR"
export DISPLAY=:0

# 3. Wake Lock
termux-wake-lock

# 4. Start PulseAudio
echo "Starting PulseAudio..."
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null

# 5. GPU Handling (VirGL/Zink)
if command -v virgl_test_server_android &> /dev/null; then
    # Simple auto-detection re-check
    if command -v glxinfo &> /dev/null; then
        renderer=$(glxinfo -B 2>/dev/null | grep "OpenGL renderer")
        if [[ "$renderer" == *"Adreno"* ]]; then
            echo "Starting VirGL Server..."
            virgl_test_server_android &
            export MESA_LOADER_DRIVER_OVERRIDE=zink
            export GALLIUM_DRIVER=zink
            export ZINK_DESCRIPTORS=lazy
        fi
    fi
fi

# 6. Start Termux:X11
echo "Starting Termux:X11..."
termux-x11 :0 -xstartup "dbus-launch --exit-with-session xfce4-session" >/dev/null 2>&1 &

# 7. Launch Activity
echo "Launching X11 Activity..."
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1

echo "Desktop started! If the screen is black, switch to the Termux:X11 app."
