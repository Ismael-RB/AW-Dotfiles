#!/bin/bash
# Actualiza el theme.conf de SDDM con el wallpaper activo y los colores wal.
# Llamado desde wallpaper-cycle.sh y wal-reload.sh después de correr wal.

THEME_DIR="/usr/local/share/sddm/themes/hypr-wal"
WAL_CACHE="$HOME/.cache/wal"
WALLPAPER=$(cat "$WAL_CACHE/wal" 2>/dev/null)

[[ -d "$THEME_DIR" ]] || exit 0
[[ -f "$WAL_CACHE/sddm-theme.conf" ]] || exit 0
[[ -n "$WALLPAPER" ]] || exit 0

# Reemplazar el placeholder con la ruta real del wallpaper
sed "s|WALLPAPER_PLACEHOLDER|$WALLPAPER|g" \
    "$WAL_CACHE/sddm-theme.conf" \
    > "$THEME_DIR/theme.conf"
