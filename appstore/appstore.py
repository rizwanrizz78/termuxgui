import tkinter as tk
from tkinter import ttk, messagebox
import subprocess
import threading
import os

# App Database
APPS = {
    "Browsers": [
        {"name": "Firefox", "pkg": "firefox", "desc": "Mozilla Firefox Web Browser"},
        {"name": "Chromium", "pkg": "chromium", "desc": "Open-source web browser project"},
    ],
    "Media": [
        {"name": "VLC", "pkg": "vlc", "desc": "Multimedia player"},
        {"name": "MPV", "pkg": "mpv", "desc": "Command line video player"},
        {"name": "FFmpeg", "pkg": "ffmpeg", "desc": "Multimedia framework"},
    ],
    "Development": [
        {"name": "VS Code (Code-Server)", "pkg": "tur-repo code-server", "desc": "Run VS Code in browser (requires tur-repo)"},
        {"name": "Git", "pkg": "git", "desc": "Version control system"},
        {"name": "NodeJS", "pkg": "nodejs", "desc": "JavaScript runtime"},
        {"name": "Python", "pkg": "python", "desc": "Python programming language"},
        {"name": "Neovim", "pkg": "neovim", "desc": "Hyperextensible Vim-based text editor"},
    ],
    "Graphics": [
        {"name": "GIMP", "pkg": "gimp", "desc": "GNU Image Manipulation Program"},
        {"name": "Inkscape", "pkg": "inkscape", "desc": "Vector graphics editor"},
    ],
    "Office": [
        {"name": "LibreOffice", "pkg": "libreoffice", "desc": "Office productivity suite"},
    ],
    "Networking": [
        {"name": "Nmap", "pkg": "nmap", "desc": "Network exploration tool"},
        {"name": "Wireshark", "pkg": "wireshark-gtk", "desc": "Network protocol analyzer"},
    ],
    "Utilities": [
        {"name": "Htop", "pkg": "htop", "desc": "Interactive process viewer"},
        {"name": "Neofetch", "pkg": "neofetch", "desc": "System information tool"},
        {"name": "Ranger", "pkg": "ranger", "desc": "Console file manager"},
    ],
    "Gaming": [
        {"name": "Moonlight", "pkg": "moonlight", "desc": "Game streaming client"},
    ]
}

class TermiDeskAppStore(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("TermiDesk App Store")
        self.geometry("900x600")

        # Style
        self.style = ttk.Style()
        self.style.theme_use('clam')

        # Layout
        self.main_container = ttk.Frame(self)
        self.main_container.pack(fill=tk.BOTH, expand=True)

        # Sidebar (Categories)
        self.sidebar = ttk.Frame(self.main_container, width=200, relief=tk.RAISED)
        self.sidebar.pack(side=tk.LEFT, fill=tk.Y)

        # Main Content Area
        self.content_area = ttk.Frame(self.main_container)
        self.content_area.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=10, pady=10)

        self.current_category = None
        self.create_sidebar()
        self.show_category("Browsers")

    def create_sidebar(self):
        lbl = ttk.Label(self.sidebar, text="Categories", font=("Arial", 14, "bold"))
        lbl.pack(pady=10, padx=5)

        for category in APPS.keys():
            btn = ttk.Button(self.sidebar, text=category, command=lambda c=category: self.show_category(c))
            btn.pack(fill=tk.X, padx=5, pady=2)

    def show_category(self, category):
        self.current_category = category

        # Clear content area
        for widget in self.content_area.winfo_children():
            widget.destroy()

        lbl = ttk.Label(self.content_area, text=category, font=("Arial", 16, "bold"))
        lbl.pack(anchor=tk.W, pady=(0, 20))

        # Scrollable Frame for Apps
        canvas = tk.Canvas(self.content_area)
        scrollbar = ttk.Scrollbar(self.content_area, orient="vertical", command=canvas.yview)
        scrollable_frame = ttk.Frame(canvas)

        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(
                scrollregion=canvas.bbox("all")
            )
        )

        canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)

        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")

        # List Apps
        for app in APPS[category]:
            self.create_app_card(scrollable_frame, app)

    def create_app_card(self, parent, app):
        card = ttk.Frame(parent, relief=tk.GROOVE, borderwidth=2)
        card.pack(fill=tk.X, pady=5, padx=5)

        name_lbl = ttk.Label(card, text=app["name"], font=("Arial", 12, "bold"))
        name_lbl.pack(side=tk.LEFT, padx=10, pady=10)

        desc_lbl = ttk.Label(card, text=app["desc"])
        desc_lbl.pack(side=tk.LEFT, padx=10)

        btn_frame = ttk.Frame(card)
        btn_frame.pack(side=tk.RIGHT, padx=10, pady=10)

        install_btn = ttk.Button(btn_frame, text="Install", command=lambda: self.install_app(app))
        install_btn.pack(side=tk.LEFT, padx=2)

        uninstall_btn = ttk.Button(btn_frame, text="Uninstall", command=lambda: self.uninstall_app(app))
        uninstall_btn.pack(side=tk.LEFT, padx=2)

    def run_pkg_command(self, action, app):
        # Open a new top-level window for logs
        log_window = tk.Toplevel(self)
        log_window.title(f"{action}ing {app['name']}...")
        log_window.geometry("600x400")

        text_area = tk.Text(log_window, wrap=tk.WORD)
        text_area.pack(fill=tk.BOTH, expand=True)

        def task():
            cmd = ["pkg", action.lower(), "-y", app["pkg"]]
            if " " in app["pkg"]: # Handle multi-word packages like "tur-repo code-server"
                 # Special handling for cases where we need to enable a repo first
                 # This is a simplification. Ideally, we split the command.
                 pkgs = app["pkg"].split()
                 if pkgs[0] == "tur-repo":
                     # Enable tur-repo first
                     process = subprocess.Popen(["pkg", "install", "-y", "tur-repo"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
                     for line in process.stdout:
                         text_area.insert(tk.END, line)
                         text_area.see(tk.END)
                     process.wait()
                     cmd = ["pkg", "install", "-y", pkgs[1]]

            text_area.insert(tk.END, f"Running: {' '.join(cmd)}\n\n")

            try:
                process = subprocess.Popen(
                    cmd,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    text=True,
                    bufsize=1,
                    universal_newlines=True
                )

                for line in process.stdout:
                    text_area.insert(tk.END, line)
                    text_area.see(tk.END)

                process.wait()

                if process.returncode == 0:
                    text_area.insert(tk.END, "\n\nSuccess!")
                    messagebox.showinfo("Success", f"{app['name']} {action}ed successfully!")
                else:
                    text_area.insert(tk.END, "\n\nFailed!")
                    messagebox.showerror("Error", f"Failed to {action} {app['name']}.")

            except Exception as e:
                text_area.insert(tk.END, f"\n\nError: {str(e)}")

        threading.Thread(target=task).start()

    def install_app(self, app):
        if messagebox.askyesno("Install", f"Install {app['name']}?"):
            self.run_pkg_command("Install", app)

    def uninstall_app(self, app):
         if messagebox.askyesno("Uninstall", f"Uninstall {app['name']}?"):
            self.run_pkg_command("Uninstall", app)

if __name__ == "__main__":
    app = TermiDeskAppStore()
    app.mainloop()
