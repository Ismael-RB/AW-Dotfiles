#!/bin/bash
# Ejecutado via exec-once en hyprland.conf al inicio de cada sesión.
# Guarda todos los configs en ~/.cache/config-backups/<timestamp>/
# Mantiene los últimos 7 backups y rota automáticamente.

LOG_DIR="$HOME/.cache/logs"
LOG="$LOG_DIR/backup-configs.log"
BACKUP_ROOT="$HOME/.cache/config-backups"
STAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DEST="$BACKUP_ROOT/$STAMP"
MAX_BACKUPS=7

mkdir -p "$DEST" "$LOG_DIR"

log() {
    printf '[%s] [%-5s] %s\n' "$(date '+%H:%M:%S')" "$1" "$2" >> "$LOG"
}

CONFIGS=(
    "$HOME/.config/hypr/hyprland.conf"
    "$HOME/.config/hypr/hyprland.lua"
    "$HOME/.config/hypr/hyprlock.conf"
    "$HOME/.config/hypr/hypridle.conf"
    "$HOME/.config/hypr/scripts/ws1-fetch.sh"
    "$HOME/.config/hypr/scripts/dashboard.sh"
    "$HOME/.config/hypr/scripts/live-stats.sh"
    "$HOME/.config/hypr/scripts/wallpaper-cycle.sh"
    "$HOME/.config/hypr/scripts/wal-reload.sh"
    "$HOME/.config/hypr/scripts/battery-notify.sh"
    "$HOME/.config/waybar/config.jsonc"
    "$HOME/.config/waybar/style.css"
    "$HOME/.config/kitty/kitty.conf"
    "$HOME/.config/mako/config"
    "$HOME/.config/fuzzel/fuzzel.ini"
    "$HOME/.config/fastfetch/config.jsonc"
    "$HOME/.config/waypaper/config.ini"
    "$HOME/.config/tmux/dashboard.conf"
    "$HOME/.zshrc"
    "/etc/sddm.conf.d/theme.conf"
    "/usr/local/share/sddm/themes/hypr-wal/Main.qml"
    "/usr/local/share/sddm/themes/hypr-wal/theme.conf"
)

log INFO "=== Sesión iniciada: $STAMP ==="

errors=0
for f in "${CONFIGS[@]}"; do
    rel="${f#"$HOME/"}"
    safe="${rel//\//__}"
    if [[ -f "$f" ]]; then
        if cp "$f" "$DEST/$safe"; then
            log INFO "OK   $rel"
        else
            log ERROR "FAIL $rel (cp falló con código $?)"
            (( errors++ ))
        fi
    else
        log WARN "MISS $rel (archivo no encontrado)"
    fi
done

# Rotar: eliminar backups viejos más allá del máximo
mapfile -t old < <(ls -dt "$BACKUP_ROOT"/*/ 2>/dev/null | tail -n +"$(( MAX_BACKUPS + 1 ))")
for d in "${old[@]}"; do
    rm -rf "$d"
    log INFO "Rotado: $(basename "$d")"
done

total=$(ls -d "$BACKUP_ROOT"/*/ 2>/dev/null | wc -l)
log INFO "=== Fin | errores: $errors | backups totales: $total ==="
