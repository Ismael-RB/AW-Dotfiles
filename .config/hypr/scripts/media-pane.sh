#!/usr/bin/env bash
# Pane derecho del dashboard.
# Idle  → animación aleatoria (elegida al arrancar)
# Play  → cava

ANIMATIONS=(
    'cmatrix -s'
    'nyancat'
    'pipes.sh -p 3 -t 1'
)
IDLE_CMD="${ANIMATIONS[$RANDOM % ${#ANIMATIONS[@]}]}"

child_pid=""

kill_child() {
    [[ -n "$child_pid" ]] && kill "$child_pid" 2>/dev/null
    wait "$child_pid" 2>/dev/null
    child_pid=""
    clear
}

run_idle() {
    kill_child
    eval "$IDLE_CMD" &
    child_pid=$!
}

run_cava() {
    kill_child
    cava &
    child_pid=$!
}

trap 'kill_child; exit 0' EXIT INT TERM

prev_status=""
run_idle

while true; do
    sleep 1
    status=$(playerctl status 2>/dev/null)
    [[ -z "$status" ]] && status="Stopped"

    if [[ "$status" == "Playing" && "$prev_status" != "Playing" ]]; then
        run_cava
    elif [[ "$status" != "Playing" && "$prev_status" == "Playing" ]]; then
        run_idle
    elif ! kill -0 "$child_pid" 2>/dev/null; then
        # proceso murió, relanzar el que corresponde
        [[ "$status" == "Playing" ]] && run_cava || run_idle
    fi

    prev_status="$status"
done
