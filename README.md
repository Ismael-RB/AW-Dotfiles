# AW-Dotfiles

Personal dotfiles for my **Alienware m16 R2** running **CachyOS Linux**.  
Configured for a fast, minimal, keyboard-driven Wayland desktop.

---

## Hardware

| Component | Spec |
|-----------|------|
| **Machine** | Alienware m16 R2 |
| **CPU** | Intel Core Ultra 7 155H |
| **GPU** | NVIDIA GeForce RTX 4050 Mobile + Intel Arc (iGPU) |
| **RAM** | 32 GB |
| **Display** | 16" — scaled at 1.6x (HiDPI) |

---

## Software Stack

| Role | Tool |
|------|------|
| **OS** | [CachyOS](https://cachyos.org) (Arch-based, optimized kernel) |
| **Compositor** | [Hyprland](https://hyprland.org) (Wayland, config in Lua) |
| **Shell** | [Fish](https://fishshell.com) |
| **Prompt** | [Starship](https://starship.rs) |
| **Terminal** | [Kitty](https://sw.kovidgoyal.net/kitty) |
| **Editor** | [Neovim](https://neovim.io) + [LazyVim](https://lazyvim.org) |
| **Bar** | [Waybar](https://github.com/Alexays/Waybar) |
| **Notifications** | [Mako](https://github.com/emersion/mako) |
| **File Manager** | [Yazi](https://github.com/sxyazi/yazi) |
| **Multiplexer** | [Tmux](https://github.com/tmux/tmux) |
| **System Monitor** | [Btop](https://github.com/aristocratos/btop) |
| **App Launcher** | [Fuzzel](https://codeberg.org/dnkl/fuzzel) |
| **Navigation** | [Zoxide](https://github.com/ajeetdsouza/zoxide) |

---

## Structure

```
.config/
├── hypr/               # Hyprland compositor (Lua config + scripts)
│   ├── hyprland.lua    # Main config
│   ├── hyprlock.conf   # Lock screen
│   ├── hypridle.conf   # Idle daemon
│   └── scripts/        # Custom shell scripts
├── waybar/             # Status bar config + CSS
├── fish/               # Shell config
├── nvim/               # Neovim (LazyVim-based)
├── kitty/              # Terminal emulator
├── tmux/               # Terminal multiplexer
├── yazi/               # Terminal file manager
├── mako/               # Notification daemon
├── fastfetch/          # System info display
├── btop/               # Resource monitor
└── starship.toml       # Shell prompt
```

---

## Notable Scripts

| Script | Description |
|--------|-------------|
| `hypr/scripts/backup-configs.sh` | Auto-backup configs on session start, keeps last 7 snapshots |
| `hypr/scripts/live-stats.sh` | Real-time CPU, RAM, GPU, battery stats in terminal |
| `hypr/scripts/dashboard.sh` | Tmux dashboard with clock, stats and audio visualizer |
| `hypr/scripts/wallpaper-cycle.sh` | Wallpaper rotation with pywal color reload |
| `hypr/scripts/zen-mode.sh` | Toggle Waybar on/off for distraction-free mode |
| `hypr/scripts/battery-notify.sh` | Battery level notifications |
| `waybar/fan-mode.sh` | Alienware fan mode switcher |
| `waybar/power-profile.sh` | Power profile switcher (performance/balanced/saver) |

---

## Hyprland Config

Written in **Lua** via `hyprland.lua` — avoids repetition and allows programmatic keybind and workspace definitions. Falls back to standard `hyprland.conf` for compatibility.

Monitor is configured at **1.6x scale** for HiDPI (1.5x caused rendering artifacts on this panel).

---

## Installation

> These are personal configs — install selectively, not blindly.

```bash
git clone https://github.com/Ismael-RB/AW-Dotfiles.git
cd AW-Dotfiles

# Copy what you need, e.g.:
cp -r .config/hypr ~/.config/
cp -r .config/fish ~/.config/
cp .config/starship.toml ~/.config/
```
