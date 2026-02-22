#!/bin/bash

# Source helper functions
source ./utils.sh

detect_gpu() {
    log_info "Detecting GPU configuration..."

    local detected_vendor="unknown"
    local detected_model="unknown"
    local recommended_driver="llvmpipe"

    # Layer 1: OpenGL Renderer Check
    if command -v glxinfo &> /dev/null; then
        renderer=$(glxinfo | grep "OpenGL renderer" | cut -d ':' -f 2 | xargs)
        if [[ "$renderer" == *"Adreno"* ]]; then
            detected_vendor="Adreno"
            recommended_driver="virgl"
            detected_model="$renderer"
        elif [[ "$renderer" == *"Mali"* ]]; then
            detected_vendor="Mali"
            recommended_driver="panfrost"
            detected_model="$renderer"
        elif [[ "$renderer" == *"Xclipse"* ]]; then
            detected_vendor="Xclipse"
            recommended_driver="experimental"
            detected_model="$renderer"
        elif [[ "$renderer" == *"llvmpipe"* ]]; then
            detected_vendor="Software"
            recommended_driver="llvmpipe"
            detected_model="$renderer"
        fi
    fi

    # Layer 2: Vulkan Check (if Layer 1 failed or unsure)
    if [[ "$detected_vendor" == "unknown" ]] && command -v vulkaninfo &> /dev/null; then
        vulkan_gpu=$(vulkaninfo 2>/dev/null | grep "GPU" | head -n 1)
        if [[ "$vulkan_gpu" == *"Adreno"* ]]; then
            detected_vendor="Adreno"
            recommended_driver="virgl"
        elif [[ "$vulkan_gpu" == *"Mali"* ]]; then
            detected_vendor="Mali"
            recommended_driver="panfrost"
        elif [[ "$vulkan_gpu" == *"Xclipse"* ]]; then
            detected_vendor="Xclipse"
            recommended_driver="experimental"
        fi
    fi

    # Layer 3: Android System Properties (if still unknown)
    if [[ "$detected_vendor" == "unknown" ]]; then
        if command -v getprop &> /dev/null; then
            hardware=$(getprop ro.hardware)
            platform=$(getprop ro.board.platform)
            board=$(getprop ro.product.board)

            if [[ "$hardware" == *"qcom"* || "$platform" == *"msm"* || "$platform" == *"sdm"* ]]; then
                detected_vendor="Adreno"
                recommended_driver="virgl"
            elif [[ "$hardware" == *"exynos"* || "$platform" == *"exynos"* ]]; then
                # Exynos usually uses Mali, but some newer ones use Xclipse (AMD)
                # We'll default to Mali/Panfrost for now, but flagging as potentially Xclipse if needed
                detected_vendor="Mali"
                recommended_driver="panfrost"
            elif [[ "$hardware" == *"mt"* || "$platform" == *"mt"* ]]; then
                detected_vendor="Mali"
                recommended_driver="panfrost"
            elif [[ "$hardware" == *"kirin"* ]]; then
                 detected_vendor="Mali"
                 recommended_driver="panfrost"
            fi
        fi
    fi

    # Layer 4: CPU Info (Last Resort)
    if [[ "$detected_vendor" == "unknown" ]]; then
        if grep -q "Qualcomm" /proc/cpuinfo; then
             detected_vendor="Adreno"
             recommended_driver="virgl"
        elif grep -q "Exynos" /proc/cpuinfo; then
             detected_vendor="Mali"
             recommended_driver="panfrost"
        fi
    fi

    # Final Fallback
    if [[ "$detected_vendor" == "unknown" ]]; then
        detected_vendor="Generic/Unknown"
        recommended_driver="llvmpipe"
    fi

    echo "VENDOR=$detected_vendor"
    echo "DRIVER=$recommended_driver"
    echo "MODEL=$detected_model"
}

configure_gpu() {
    local driver=$1
    log_info "Configuring GPU for driver: $driver"

    case $driver in
        "virgl")
            # Commands to setup VirGL
            # Example: export MESA_LOADER_DRIVER_OVERRIDE=zink (if applicable) or similar
            # For Termux-X11 usually it's just ensuring mesa-zink or virglrenderer is installed
            pkg install -y mesa-zink virglrenderer-android
            ;;
        "panfrost")
            # Commands to setup Panfrost
            pkg install -y mesa
            # export MESA_LOADER_DRIVER_OVERRIDE=panfrost
            ;;
        "experimental")
            log_warning "Experimental GPU detected (AMD Xclipse/Other). Using Zink/VirGL stack as best effort."
            pkg install -y mesa-zink virglrenderer-android
            ;;
        "llvmpipe")
            # Software rendering
            pkg install -y mesa
            # export LIBGL_ALWAYS_SOFTWARE=1
            ;;
        *)
            log_warning "Unknown driver configuration. Defaulting to software."
            pkg install -y mesa
            ;;
    esac
}
