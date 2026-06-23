#!/bin/bash
# Mantiene el dashboard en workspace 1.
# Relanza la ventana si se cierra y controla el límite de ventanas extras.

# ── Configuración ───────────────────────────────────────────
WS1_MAX_EXTRA=0   # ventanas extras permitidas en ws1 además del dashboard (0 = solo dashboard)

LOG_DIR="$HOME/.cache/logs"
LOG="$LOG_DIR/ws1-fetch.log"
MAX_LOG_BYTES=102400

mkdir -p "$LOG_DIR"

log() {
    printf '[%s] [%-5s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "$2" >> "$LOG"
}

rotate_log() {
    local size
    size=$(stat -c%s "$LOG" 2>/dev/null) || return
    if (( size > MAX_LOG_BYTES )); then
        mv "$LOG" "${LOG}.1"
        log INFO "Log rotado (superó $MAX_LOG_BYTES bytes)"
    fi
}

launch_fetch() {
    log INFO "Lanzando dashboard en ws1..."
    local out
    out=$(hyprctl dispatch -- exec \
        "[workspace 1 silent] kitty --title dashboard zsh -c '~/.config/hypr/scripts/dashboard.sh'" 2>&1)
    local code=$?
    if (( code == 0 )); then
        log INFO "Dispatch OK"
    else
        log ERROR "Dispatch falló (código $code): $out"
    fi
}

handle() {
    case $1 in
        openwindow*)
            # Evento: openwindow>>address,workspacename,class,title
            local addr wname class title
            IFS=',' read -r addr wname class title <<< "${1#openwindow>>}"

            [[ "$wname" != "1" || "$title" == "dashboard" ]] && return

            sleep 0.15

            local extra
            extra=$(hyprctl clients -j 2>/dev/null \
                | jq '[.[] | select(.workspace.id == 1 and .title != "dashboard")] | length' 2>/dev/null)

            if (( ${extra:-0} > WS1_MAX_EXTRA )); then
                hyprctl dispatch movetoworkspacesilent 2,address:0x${addr} 2>/dev/null
                log INFO "Ventana '$title' movida a ws2 (límite ws1: $WS1_MAX_EXTRA extra)"
            else
                log INFO "Ventana '$title' permitida en ws1 (extra: ${extra:-0}/$WS1_MAX_EXTRA)"
            fi
            ;;

        closewindow*)
            sleep 0.3
            local count
            count=$(hyprctl clients -j 2>/dev/null \
                | jq '[.[] | select(.workspace.id == 1)] | length' 2>/dev/null)
            if [[ -z "$count" ]]; then
                log WARN "No se pudo leer clientes de hyprctl"
                return
            fi
            log INFO "Ventanas en ws1: $count"
            if (( count == 0 )); then
                launch_fetch
            fi
            ;;
    esac
}

rotate_log
log INFO "=== Script iniciado (WS1_MAX_EXTRA=$WS1_MAX_EXTRA) ==="

for dep in hyprctl socat jq; do
    if ! command -v "$dep" &>/dev/null; then
        log ERROR "Dependencia faltante: $dep — abortando"
        exit 1
    fi
done

sleep 2
launch_fetch

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

if [[ ! -S "$SOCKET" ]]; then
    log ERROR "Socket no encontrado: $SOCKET"
    exit 1
fi

log INFO "Conectando a socket: $SOCKET"

socat -u "UNIX-CONNECT:$SOCKET" - 2>>"$LOG" | while IFS= read -r line; do
    handle "$line"
done

log WARN "socat desconectado — script terminado"
