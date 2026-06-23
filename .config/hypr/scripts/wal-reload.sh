#!/bin/bash
pkill -x mako
pkill -x waybar

sleep 0.1

mako &
waybar &

tmux source-file ~/.cache/wal/tmux-wal.conf 2>/dev/null || true
~/.config/hypr/scripts/sddm-theme-update.sh 2>/dev/null || true
