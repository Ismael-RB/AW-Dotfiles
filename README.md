# AW-Dotfiles

Personal dotfiles for my **Alienware m16 R2** running **CachyOS Linux**.  
Configured for a fast, minimal, keyboard-driven Wayland desktop.

![Desktop Preview](assets/preview.png)
![Clean Desktop](assets/preview2.png)

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
├── hypr/                          # Hyprland compositor (Lua config + scripts)
│   ├── hyprland.lua               # Main config
│   ├── hyprlock.conf              # Lock screen
│   ├── hypridle.conf              # Idle daemon
│   └── scripts/                   # Custom shell scripts
├── pipewire/filter-chain.conf.d/  # PipeWire speaker EQ (9-band LV2 + limiter)
├── wireplumber/                   # WirePlumber default sink routing
├── waybar/                        # Status bar config + CSS
├── fish/                          # Shell config
├── nvim/                          # Neovim (LazyVim-based)
├── kitty/                         # Terminal emulator
├── tmux/                          # Terminal multiplexer
├── yazi/                          # Terminal file manager
├── fastfetch/                     # System info display
├── btop/                          # Resource monitor
└── starship.toml                  # Shell prompt

system/
└── alienware-fan/
    ├── alienware-fan              # Fan + CPU governor daemon
    └── alienware-fan.service      # systemd service
```

---

## Audio Tuning

Custom **9-band parametric EQ** via PipeWire + LSP LV2 plugins (`para_equalizer_x16_stereo`), tuned specifically for the Alienware m16 R2's side-firing 2W speakers:

| Band | Type | Freq | Gain | Purpose |
|------|------|------|------|---------|
| 0 | Lo-shelf | 80 Hz | −3.5 dB | Cuts sub-bass the drivers can't reproduce |
| 1 | Bell | 130 Hz | +2.5 dB | Boosts real bass where the driver has energy |
| 2 | Bell | 180 Hz | −1.5 dB | Removes cabinet resonance |
| 3 | Bell | 380 Hz | −1.5 dB | Cuts nasal coloration from the plastic enclosure |
| 4 | Bell | 2500 Hz | +1.5 dB | Restores presence and clarity |
| 5 | Bell | 5000 Hz | −2.0 dB | Tames lateral sibilance |
| 6 | Bell | 6500 Hz | −1.0 dB | Smooth transition into the hi-shelf |
| 7 | Hi-shelf | 8000 Hz | +3.5 dB | Recovers air lost from the side-firing angle |
| 8 | Bell | 12000 Hz | +1.5 dB | Restores high-end presence |

- Preamp: −4.5 dB (headroom for the boosts)
- Stereo limiter: −2 dB threshold, 50 ms release — prevents clipping at max volume

Config: `.config/pipewire/filter-chain.conf.d/speakers-eq.conf`

---

## Fan & CPU Control

Custom systemd daemon (`system/alienware-fan/`) that manages ACPI platform profiles and CPU energy performance preferences based on power source and thermal state:

| Mode | Profile | EPP |
|------|---------|-----|
| `low` | quiet | power |
| `normal` | balanced-performance | balance_power |
| `gaming` | performance | performance |
| battery | quiet | power |
| emergency (>80°C for 45s) | performance | performance |

Switches back to normal automatically when temperature drops below 72°C.  
Mode is set via Waybar buttons — no manual editing needed.

**Install:**
```bash
sudo cp system/alienware-fan/alienware-fan /usr/local/bin/
sudo chmod +x /usr/local/bin/alienware-fan
sudo cp system/alienware-fan/alienware-fan.service /etc/systemd/system/
sudo systemctl enable --now alienware-fan
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

## Wallpaper

[Wallhaven — 1qg3q9](https://wallhaven.cc/w/1qg3q9) — Licensed CC0 (public domain)

Wallpapers are **not included** in this repo. All images remain property of their original owners.

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
