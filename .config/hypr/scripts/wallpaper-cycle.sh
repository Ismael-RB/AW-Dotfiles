#!/bin/bash
WALL_DIR="$HOME/Pictures/Wallpapers"
CACHE="$HOME/.cache/wallpaper-index"

mapfile -t walls < <(find "$WALL_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | sort)
total=${#walls[@]}
[[ $total -eq 0 ]] && exit 1

idx=0
[[ -f "$CACHE" ]] && read -r idx < "$CACHE"
idx=$(( idx % total ))

case "${1:-next}" in
    prev)    idx=$(( (idx - 1 + total) % total )) ;;
    current) : ;;
    *)       idx=$(( (idx + 1) % total ))          ;;
esac

echo "$idx" > "$CACHE"
new_wall="${walls[$idx]}"

awww img "$new_wall" \
    --transition-type fade \
    --transition-duration 1.5 \
    --transition-fps 60

SDDM_THEME="/usr/share/sddm/themes/hypr-minimal"
[[ -d "$SDDM_THEME" ]] && cp "$new_wall" "$SDDM_THEME/current.jpg"

