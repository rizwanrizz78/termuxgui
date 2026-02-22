# TermiDesk: The Native Linux Desktop for Termux

**TermiDesk** is an advanced, modular, and highly customizable desktop environment running natively inside Termux. It leverages Termux:X11 and XFCE4 to provide a full Linux desktop experience on your Android device, optimized for performance and touch interaction.

## 🚀 Why TermiDesk?

Unlike other Termux desktop scripts, TermiDesk is built with a **dual-mode installer**, **automatic GPU acceleration detection**, and a built-in **App Store**. It is designed to be plug-and-play while offering deep customization for power users.

## ✨ Features

- **GPU Acceleration**: Automatically detects Adreno (VirGL) and Mali (Panfrost) GPUs for optimal performance. Fallback to software rendering (LLVMpipe) ensures compatibility on all devices.
- **Dual Installer**:
    - **Recommended**: One-click setup with best defaults.
    - **Manual**: Granular control over every component (Desktop, GPU, Apps, Themes).
- **Built-in App Store**: A lightweight GUI to easily install and manage Linux applications (Browsers, Dev Tools, Media, etc.).
- **Performance Modes**: Optimized for mobile with touch-friendly layouts and lightweight themes.
- **Tool Bundles**: Pre-configured sets for Developers, Creators, and Media consumption.

## 📦 Installation

### Prerequisites

- Android 10+
- Termux (from F-Droid)
- Termux:X11 (installed via pkg or GitHub artifact)

### 1️⃣ Recommended Setup (Easiest)

Installs XFCE4, auto-configures GPU, and adds essential apps.

```bash
pkg update && pkg upgrade
pkg install git
git clone https://github.com/yourusername/TermiDesk.git
cd TermiDesk
bash install.sh --recommended
```

### 2️⃣ Manual Setup (Custom)

Interactive menu to select specific components.

```bash
bash install.sh --manual
```

## 📸 Screenshots

*(Add screenshots of Desktop, App Store, and Installer here)*

## 🎨 Customization Guide

### Changing Themes
Themes are stored in `~/.themes`. You can use the XFCE Settings Manager to switch themes. TermiDesk comes with a few optimized presets.

### Wallpapers
Place your images in `~/.wallpapers`. You can change the wallpaper via `Right Click -> Desktop Settings`.

### App Store
Launch the App Store from the Desktop shortcut or run:
```bash
python ~/TermiDesk/appstore/appstore.py
```

## 🎮 GPU Support

TermiDesk attempts to auto-detect your GPU vendor:

| GPU Vendor | Driver | Status |
| :--- | :--- | :--- |
| **Adreno** (Snapdragon) | VirGL | ✅ Stable, High Performance |
| **Mali** (Exynos/MediaTek) | Panfrost | ⚠️ Experimental/Varies |
| **Other** | LLVMpipe | ✅ Stable, Software Rendering |

You can override the detection in the **Manual Installer**.

## 🛠 Troubleshooting

**Q: The desktop doesn't start.**
A: Ensure you are running `termux-x11` and have the X11 app open on your Android device.

**Q: Black screen on launch.**
A: Try re-running the installer and selecting "Software Rendering" (LLVMpipe) for the GPU.

**Q: App Store crashes.**
A: Ensure `python-tkinter` is installed: `pkg install python-tkinter`.

## 🤝 Contributing

We welcome contributions!
1.  Fork the repository.
2.  Create a feature branch.
3.  Submit a Pull Request.

Please see `CONTRIBUTING.md` (coming soon) for more details.

## 📜 License

This project is licensed under the **MIT License**.
