#!/bin/bash

# Source helper functions
if [ -f "./utils.sh" ]; then
    source ./utils.sh
elif [ -f "../utils.sh" ]; then
    source ../utils.sh
fi

enable_performance_mode() {
    log_info "Enabling Performance Mode..."

    # 1. Disable XFCE Compositing (Improves responsiveness on low-end devices)
    # This requires xfconfd to be running, which might not be the case during install.
    # We can try to modify the XML directly if xfconf-query fails or isn't running.
    if command -v xfconf-query &> /dev/null; then
        log_info "Disabling Window Compositing..."
        # We need a running X server for xfconf-query usually, or we can use -n -t bool -s false to create if missing
        # But if D-Bus isn't running, this fails.
        # Fallback to direct XML edit if needed.
        xfconf-query -c xfwm4 -p /general/use_compositing -s false || log_warning "Could not set compositing via xfconf-query (X server not running?)"
    else
        log_warning "xfconf-query not found. Is XFCE installed? Skipping compositing tweak."
    fi

    # 2. Set Environment Variables for Performance
    log_info "Optimizing Environment Variables..."
    if ! grep -q "MOZ_ACCELERATED" ~/.bashrc; then
        echo "export MOZ_ACCELERATED=1" >> ~/.bashrc
        echo "export MOZ_WEBRENDER=1" >> ~/.bashrc
    fi

    # 3. Suggest ZRAM/Swap
    log_info "Checking for ZRAM/Swap status..."
    if [ -e /proc/swaps ]; then
        if grep -q "zram" /proc/swaps; then
            log_success "ZRAM appears to be active."
        else
            log_warning "ZRAM not detected. For better performance on low RAM devices, consider enabling ZRAM (requires root)."
        fi
    fi

    log_success "Performance Mode Enabled."
}

disable_performance_mode() {
    log_info "Disabling Performance Mode..."
    if command -v xfconf-query &> /dev/null; then
        xfconf-query -c xfwm4 -p /general/use_compositing -s true || true
    fi
}
