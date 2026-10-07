<div align="center">

---

This repo is my personal clone of [hyprquickshell](https://github.com/devpryan7792/hyprquickshell). I have made some small changes, but will continually expand as I learn more.


## ⌨️ Keybindings Cheat Sheet

| Keybinding | Action |
| :--- | :--- |
| `SUPER + SPACE` | Toggle Spotlight Application Launcher |
| `SUPER + N` | Toggle Control Center / Dashboard Side Panel |
| `SUPER + W` | Toggle Wallpaper Picker & Dynamic Theme Switcher |
| `ALT + T` | Open Curated Theme Preset Studio |
| `SUPER + /` | Open Interactive Keybindings Cheatsheet |
| `SUPER + V` | Open Clipboard History (cliphist) |
| `SUPER + Q` | Launch Ghostty Terminal |
| `SUPER + E` | Open Thunar File Manager |
| `SUPER + B` | Launch Default Web Browser |
| `SUPER + F4` | Close / Kill Active Window |
| `SUPER + T` | Toggle Window Floating |
| `SUPER + F` | Toggle Fullscreen |
| `SUPER + \`` / `SUPER + U` | **Toggle Seamless Scratchpad Floating Terminal** |
| `SUPER + S` | Toggle Magic Special Workspace |
| `SUPER + [1-9]` | Switch to Workspace 1-9 |
| `SUPER + SHIFT + [1-9]` | Move Window to Workspace 1-9 |
| `SUPER + ALT + Arrows/Vim` | Resize Active Window |
| `SUPER + ALT + N` | Cycle Blue Light / Night Light (Off → 4500K → 3500K → 2700K) |
| `Print` | Interactive Region Screenshot (copies to clipboard & saves to `~/Pictures/shots`) |
| `SUPER + SHIFT + R` | Start / Stop Region Screen Recording (`~/Videos/recordings`) |
| `SUPER + X` | Power & Session Menu |
| `SUPER + M` | Exit Hyprland Compositor |

---

## Installation

### 1. Clone the Repository
```bash
git clone https://github.com/devpryan7792/hyprquickshell.git ~/hyprquickshell
cd ~/hyprquickshell
```

### 2. Run the Turnkey Installer
```bash
chmod +x install.sh
./install.sh
```

> **Options:**
> - `./install.sh -s` — **Symlink mode**: Creates live symlinks from `~/.config` to the repo (recommended for development & personal tweaking).
> - `./install.sh -c` — **Copy mode**: Copies dotfiles to `~/.config` independently.
> - `./install.sh -y` — **Unattended mode**: Automatically answers yes to all prompts.
> - `./install.sh --no-pkg` — Skips package installation and deploys dotfiles only.
---

## 🔄 Uninstallation & Backup Restore

To cleanly remove the rice configurations or restore your previous desktop setup:
```bash
cd ~/hyprquickshell
./uninstall.sh
```
If an installation backup exists, `uninstall.sh` will prompt to automatically restore your original dotfiles.

---

