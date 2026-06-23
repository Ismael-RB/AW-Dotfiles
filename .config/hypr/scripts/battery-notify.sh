#!/usr/bin/env bash
# Notificaciones de batería

BAT_CAP=$(ls /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
BAT_STS=$(ls /sys/class/power_supply/BAT*/status   2>/dev/null | head -1)
AC_PATH=$(ls /sys/class/power_supply/AC*/online    2>/dev/null | head -1)

[[ -f "$BAT_CAP" ]] || exit 1

prev_cap=$(< "$BAT_CAP")
prev_ac=$(< "$AC_PATH" 2>/dev/null || echo "1")

notify() {
    notify-send -a "battery" -t 6000 "${1}" "${2}"
}

while true; do
    sleep 30

    cap=$(< "$BAT_CAP")
    status=$(< "$BAT_STS")
    ac=$(< "$AC_PATH" 2>/dev/null || echo "1")

    # Cargador conectado / desconectado
    if [[ "$ac" != "$prev_ac" ]]; then
        if [[ "$ac" == "1" ]]; then
            notify "charger connected" "${cap}%"
        else
            notify "charger disconnected" "${cap}%"
        fi
    fi

    # Batería baja (descargando)
    if [[ "$status" == "Discharging" ]]; then
        (( cap <= 10 && prev_cap > 10 )) && \
            notify-send -u critical -a "battery" -t 0 "critical battery" "${cap}% — plug in now"
        (( cap <= 20 && prev_cap > 20 )) && \
            notify "low battery" "${cap}%"
    fi

    # Hitos de carga
    if [[ "$status" == "Charging" ]]; then
        (( cap >= 80 && prev_cap < 80 )) && \
            notify "80% reached" "consider unplugging"
        (( cap >= 100 && prev_cap < 100 )) && \
            notify "fully charged" ""
    fi

    prev_cap=$cap
    prev_ac=$ac
done
