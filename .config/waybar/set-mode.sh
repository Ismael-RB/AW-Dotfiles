#!/bin/bash

MODE_FILE="/etc/alienware-fan/ac_mode"
MONITOR="eDP-1"
SCALE="1.6"
RES="2560x1600"

current=$(cat "$MODE_FILE" 2>/dev/null || echo "normal")

case "$current" in
    normal) next="gaming" ;;
    gaming) next="low"    ;;
    low)    next="normal" ;;
    *)      next="normal" ;;
esac

echo "$next" > "$MODE_FILE"

case "$next" in
    gaming) hyprctl keyword monitor "$MONITOR,${RES}@240,0x0,$SCALE" ;;
    *)      hyprctl keyword monitor "$MONITOR,${RES}@60,0x0,$SCALE"  ;;
esac

pkill -SIGRTMIN+9 waybar
