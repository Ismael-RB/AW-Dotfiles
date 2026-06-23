#!/usr/bin/env bash
# Notificaciones de bluetooth

bluetoothctl --monitor | while IFS= read -r line; do
    if [[ "$line" =~ \[CHG\]\ Device\ ([A-F0-9:]+)\ Connected:\ yes ]]; then
        mac="${BASH_REMATCH[1]}"
        name=$(bluetoothctl info "$mac" 2>/dev/null \
               | awk -F': ' '/^\s+Name:/{print $2; exit}')
        notify-send -a "bluetooth" -t 5000 "connected" "${name:-$mac}"

    elif [[ "$line" =~ \[CHG\]\ Device\ ([A-F0-9:]+)\ Connected:\ no ]]; then
        mac="${BASH_REMATCH[1]}"
        name=$(bluetoothctl info "$mac" 2>/dev/null \
               | awk -F': ' '/^\s+Name:/{print $2; exit}')
        notify-send -a "bluetooth" -t 5000 "disconnected" "${name:-$mac}"
    fi
done
