#!/bin/bash
# Restaura configs desde un backup guardado por backup-configs.sh
# Uso:
#   ./restore-configs.sh              → muestra lista y pregunta cuál
#   ./restore-configs.sh 2025-05-21_10-30-00  → restaura ese backup directamente

BACKUP_ROOT="$HOME/.cache/config-backups"
LOG="$HOME/.cache/logs/backup-configs.log"

log() {
    printf '[%s] [%-7s] %s\n' "$(date '+%H:%M:%S')" "RESTORE" "$1" | tee -a "$LOG"
}

die() {
    echo "Error: $1" >&2
    log "ERROR: $1"
    exit 1
}

# Elegir backup
if [[ -n "$1" ]]; then
    BACKUP="$BACKUP_ROOT/$1"
else
    mapfile -t backups < <(ls -dt "$BACKUP_ROOT"/*/ 2>/dev/null)
    if [[ ${#backups[@]} -eq 0 ]]; then
        die "No hay backups en $BACKUP_ROOT"
    fi
    echo "Backups disponibles (más reciente primero):"
    for i in "${!backups[@]}"; do
        echo "  [$i] $(basename "${backups[$i]}")"
    done
    echo ""
    read -rp "Número a restaurar: " idx
    [[ "$idx" =~ ^[0-9]+$ ]] || die "Índice inválido"
    [[ "$idx" -lt "${#backups[@]}" ]] || die "Índice fuera de rango"
    BACKUP="${backups[$idx]}"
fi

[[ -d "$BACKUP" ]] || die "Backup no encontrado: $BACKUP"

log "Restaurando desde: $(basename "$BACKUP")"
echo "Restaurando $(basename "$BACKUP")..."

errors=0
for f in "$BACKUP"/*; do
    [[ -f "$f" ]] || continue
    safe="$(basename "$f")"
    rel="${safe//__//}"
    dest="$HOME/$rel"
    mkdir -p "$(dirname "$dest")"
    if cp "$f" "$dest"; then
        log "OK   $rel"
        echo "  OK  $rel"
    else
        log "ERR  $rel (código $?)"
        echo "  ERR $rel"
        (( errors++ ))
    fi
done

log "Restauración completada | errores: $errors"
echo ""
echo "Restauración completada (errores: $errors)."
echo "Reinicia las aplicaciones afectadas o ejecuta: hyprctl reload"
