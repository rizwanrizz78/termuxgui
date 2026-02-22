import tkinter as tk
from tkinter import ttk, messagebox
import subprocess
import threading
import shutil
import os

# App Database
APPS = {
    "Browsers": [
        {"name": "Firefox", "pkg": "firefox", "desc": "Mozilla Firefox Web Browser", "exec": "firefox"},
        {"name": "Chromium", "pkg": "chromium", "desc": "Open-source web browser project", "exec": "chromium"},
    ],
    "Media": [
        {"name": "VLC", "pkg": "vlc", "desc": "Multimedia player", "exec": "vlc"},
        {"name": "MPV", "pkg": "mpv", "desc": "Command line video player", "exec": "mpv"},
        {"name": "FFmpeg", "pkg": "ffmpeg", "desc": "Multimedia framework", "exec": "ffmpeg"},
    ],
    "Development": [
        {"name": "VS Code (Code-Server)", "pkg": "tur-repo code-server", "desc": "Run VS Code in browser (requires tur-repo)", "exec": "code-server"},
        {"name": "Git", "pkg": "git", "desc": "Version control system", "exec": "git"},
        {"name": "NodeJS", "pkg": "nodejs", "desc": "JavaScript runtime", "exec": "node"},
        {"name": "Python", "pkg": "python", "desc": "Python programming language", "exec": "python3"},
        {"name": "Neovim", "pkg": "neovim", "desc": "Hyperextensible Vim-based text editor", "exec": "nvim"},
    ],
    "Graphics": [
        {"name": "GIMP", "pkg": "gimp", "desc": "GNU Image Manipulation Program", "exec": "gimp"},
        {"name": "Inkscape", "pkg": "inkscape", "desc": "Vector graphics editor", "exec": "inkscape"},
    ],
    "Office": [
        {"name": "LibreOffice", "pkg": "libreoffice", "desc": "Office productivity suite", "exec": "libreoffice"},
    ],
    "Networking": [
        {"name": "Nmap", "pkg": "nmap", "desc": "Network exploration tool", "exec": "nmap"},
        {"name": "Wireshark", "pkg": "wireshark-gtk", "desc": "Network protocol analyzer", "exec": "wireshark"},
    ],
    "Utilities": [
        {"name": "Htop", "pkg": "htop", "desc": "Interactive process viewer", "exec": "htop"},
        {"name": "Neofetch", "pkg": "neofetch", "desc": "System information tool", "exec": "neofetch"},
        {"name": "Ranger", "pkg": "ranger", "desc": "Console file manager", "exec": "ranger"},
    ],
    "Gaming": [
        {"name": "Moonlight", "pkg": "moonlight", "desc": "Game streaming client", "exec": "moonlight"},
    ]
}

def is_app_installed(app):
    """Check if an app is installed by looking for its executable or package status."""
    if "exec" in app and shutil.which(app["exec"]):
        return True

    # Fallback: Check package status via dpkg
    pkg_name = app["pkg"].split()[-1] # Handle "tur-repo code-server"
    try:
        subprocess.check_output(["dpkg", "-s", pkg_name], stderr=subprocess.STDOUT)
        return True
    except subprocess.CalledProcessError:
        return False

class TermiDeskAppStore(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("TermiDesk App Store")
        self.geometry("1000x700")

        # Set window icon (if we had one)
        # try:
        #     self.iconphoto(False, tk.PhotoImage(file='icon.png'))
        # except: pass

        # Style
        self.style = ttk.Style()
        self.style.theme_use('clam')

        # Layout
        self.main_container = ttk.Frame(self)
        self.main_container.pack(fill=tk.BOTH, expand=True)

        # Header (Search)
        self.header_frame = ttk.Frame(self.main_container, height=50)
        self.header_frame.pack(side=tk.TOP, fill=tk.X, padx=10, pady=10)

        self.search_var = tk.StringVar()
        self.search_var.trace("w", self.on_search)
        search_entry = ttk.Entry(self.header_frame, textvariable=self.search_var, font=("Arial", 12))
        search_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 10))
        search_entry.insert(0, "Search apps...")
        search_entry.bind("<FocusIn>", lambda e: search_entry.delete(0, tk.END) if search_entry.get() == "Search apps..." else None)

        search_btn = ttk.Button(self.header_frame, text="Search", command=self.on_search)
        search_btn.pack(side=tk.RIGHT)

        # Sidebar (Categories)
        self.sidebar = ttk.Frame(self.main_container, width=200, relief=tk.RAISED)
        self.sidebar.pack(side=tk.LEFT, fill=tk.Y)

        # Main Content Area
        self.content_area = ttk.Frame(self.main_container)
        self.content_area.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=10, pady=10)

        self.current_category = "All Apps"
        self.create_sidebar()
        self.show_category("All Apps")

    def create_sidebar(self):
        lbl = ttk.Label(self.sidebar, text="Categories", font=("Arial", 14, "bold"))
        lbl.pack(pady=10, padx=5)

        home_btn = ttk.Button(self.sidebar, text="All Apps", command=lambda: self.show_category("All Apps"))
        home_btn.pack(fill=tk.X, padx=5, pady=2)

        ttk.Separator(self.sidebar, orient="horizontal").pack(fill=tk.X, padx=5, pady=5)

        for category in APPS.keys():
            btn = ttk.Button(self.sidebar, text=category, command=lambda c=category: self.show_category(c))
            btn.pack(fill=tk.X, padx=5, pady=2)

    def on_search(self, *args):
        query = self.search_var.get().lower()
        if query == "search apps...":
            return

        # Filter all apps
        filtered_apps = []
        for cat, app_list in APPS.items():
            for app in app_list:
                if query in app["name"].lower() or query in app["desc"].lower():
                    filtered_apps.append(app)

        self.render_app_list(filtered_apps, f"Search Results: {query}")

    def show_category(self, category):
        self.current_category = category
        app_list = []
        if category == "All Apps":
            for cat in APPS.values():
                app_list.extend(cat)
        else:
            app_list = APPS.get(category, [])

        self.render_app_list(app_list, category)

    def render_app_list(self, app_list, title):
        # Clear content area
        for widget in self.content_area.winfo_children():
            widget.destroy()

        lbl = ttk.Label(self.content_area, text=title, font=("Arial", 16, "bold"))
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
        if not app_list:
            ttk.Label(scrollable_frame, text="No apps found.").pack(pady=20)
        else:
            for app in app_list:
                self.create_app_card(scrollable_frame, app)

    def create_app_card(self, parent, app):
        card = ttk.Frame(parent, relief=tk.GROOVE, borderwidth=2)
        card.pack(fill=tk.X, pady=5, padx=5)

        # Icon Placeholder (Left) - using a label with color or text for now
        icon_lbl = ttk.Label(card, text="📦", font=("Arial", 24))
        icon_lbl.pack(side=tk.LEFT, padx=10, pady=10)

        info_frame = ttk.Frame(card)
        info_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5)

        name_lbl = ttk.Label(info_frame, text=app["name"], font=("Arial", 12, "bold"))
        name_lbl.pack(anchor=tk.W, pady=(5, 0))

        desc_lbl = ttk.Label(info_frame, text=app["desc"])
        desc_lbl.pack(anchor=tk.W)

        btn_frame = ttk.Frame(card)
        btn_frame.pack(side=tk.RIGHT, padx=10, pady=10)

        installed = is_app_installed(app)

        if installed:
            open_btn = ttk.Button(btn_frame, text="Open", command=lambda: self.launch_app(app))
            open_btn.pack(side=tk.LEFT, padx=2)

            uninstall_btn = ttk.Button(btn_frame, text="Uninstall", command=lambda: self.uninstall_app(app))
            uninstall_btn.pack(side=tk.LEFT, padx=2)
        else:
            install_btn = ttk.Button(btn_frame, text="Install", command=lambda: self.install_app(app))
            install_btn.pack(side=tk.LEFT, padx=2)

    def run_pkg_command(self, action, app):
        # Open a new top-level window for logs
        log_window = tk.Toplevel(self)
        log_window.title(f"{action}ing {app['name']}...")
        log_window.geometry("600x400")

        text_area = tk.Text(log_window, wrap=tk.WORD)
        text_area.pack(fill=tk.BOTH, expand=True)

        def task():
            # Use non-interactive flags
            cmd = ["pkg", action.lower(), "-y", "-o", 'Dpkg::Options::="--force-confnew"', app["pkg"]]
            if " " in app["pkg"]:
                 pkgs = app["pkg"].split()
                 if pkgs[0] == "tur-repo":
                     process = subprocess.Popen(["pkg", "install", "-y", "tur-repo"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
                     for line in process.stdout:
                         text_area.insert(tk.END, line)
                         text_area.see(tk.END)
                     process.wait()
                     cmd = ["pkg", "install", "-y", "-o", 'Dpkg::Options::="--force-confnew"', pkgs[1]]

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
                    # Refresh the current view to update buttons
                    self.after(100, lambda: self.show_category(self.current_category))
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

    def launch_app(self, app):
        if "exec" in app:
            subprocess.Popen(app["exec"], shell=True)
        else:
            messagebox.showinfo("Launch", f"Cannot launch {app['name']} directly.")

if __name__ == "__main__":
    app = TermiDeskAppStore()
    app.mainloop()
