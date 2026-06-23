#!/usr/bin/env bash
# Live system stats — dashboard

GRN='\033[0;32m' YLW='\033[0;33m' RED='\033[0;31m'
CYN='\033[0;36m' WHT='\033[1;37m'
DIM='\033[2m'    BLD='\033[1m'    RST='\033[0m'

goto() { printf '\033[%d;%dH' "$1" "$2"; }
clrl() { printf '\033[2K'; }

pct_color() {
    (( $1 >= 80 )) && { printf '%s' "$RED"; return; }
    (( $1 >= 55 )) && { printf '%s' "$YLW"; return; }
    printf '%s' "$GRN"
}

cpu_stat() { awk '/^cpu /{for(i=2;i<=NF;i++) t+=$i; print $5, t; exit}' /proc/stat; }

cpu_temp() {
    local f zone_type temp_raw
    for f in /sys/class/thermal/thermal_zone*/type; do
        zone_type=$(< "$f" 2>/dev/null)
        if [[ "$zone_type" == x86_pkg_temp || "$zone_type" == *cpu* ]]; then
            temp_raw=$(< "${f%type}temp" 2>/dev/null)
            echo $(( temp_raw / 1000 ))
            return
        fi
    done
    temp_raw=$(< /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
    echo $(( ${temp_raw:-0} / 1000 ))
}

HOST=$(hostname)
KERNEL=$(uname -r | cut -d- -f1)
NET_IF=$(ip route 2>/dev/null | awk '/^default/{print $5; exit}')
IS_WIFI=false
[[ "$NET_IF" == w* ]] && IS_WIFI=true

trap 'printf "\033[?25h"; tput rmcup 2>/dev/null; exit 0' EXIT INT TERM
tput smcup 2>/dev/null
printf '\033[?25l'
clear

printf "\n"
printf "   ${CYN}${BLD}%s${RST}\n" "$HOST"
printf "   ${DIM}%s · hyprland${RST}\n" "$KERNEL"
printf "\n"

STAT_ROW=5

read -r idle1 total1 < <(cpu_stat)
rx_prev=0 tx_prev=0
[[ -n "$NET_IF" ]] && {
    rx_prev=$(< /sys/class/net/"$NET_IF"/statistics/rx_bytes 2>/dev/null) || rx_prev=0
    tx_prev=$(< /sys/class/net/"$NET_IF"/statistics/tx_bytes 2>/dev/null) || tx_prev=0
}

while true; do
    sleep 1
    r=$STAT_ROW

    # ── cpu ────────────────────────────────────────────────
    read -r idle2 total2 < <(cpu_stat)
    dt=$(( total2 - total1 )); di=$(( idle2 - idle1 ))
    cpu_pct=$(( dt > 0 ? (100 - di * 100 / dt) : 0 ))
    total1=$total2; idle1=$idle2
    temp_c=$(cpu_temp)
    c=$(pct_color $cpu_pct)
    goto $r 1; clrl
    printf "   ${DIM}cpu   ${RST}${c}%d%%${RST}" "$cpu_pct"
    (( temp_c > 0 )) && printf "   ${DIM}%d°c${RST}" "$temp_c"
    (( r++ ))

    # ── ram ────────────────────────────────────────────────
    read -r ram_used ram_total < <(free -m | awk '/^Mem:/{print $3,$2}')
    ram_pct=$(( ram_total > 0 ? ram_used * 100 / ram_total : 0 ))
    c=$(pct_color $ram_pct)
    goto $r 1; clrl
    printf "   ${DIM}ram   ${RST}${c}%dM${RST}${DIM} / ${RST}${WHT}%dM${RST}" "$ram_used" "$ram_total"
    (( r++ ))

    # ── disk ───────────────────────────────────────────────
    read -r disk_used disk_total disk_pct < <(df -h / | awk 'NR==2{gsub(/%/,"",$5); print $3,$2,$5}')
    c=$(pct_color "${disk_pct:-0}")
    goto $r 1; clrl
    printf "   ${DIM}disk  ${RST}${c}%s${RST}${DIM} / ${RST}${WHT}%s${RST}" "$disk_used" "$disk_total"
    (( r++ ))

    # ── blank ──────────────────────────────────────────────
    goto $r 1; clrl; (( r++ ))

    # ── bat ────────────────────────────────────────────────
    bat_f=$(ls /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
    if [[ -n "$bat_f" ]]; then
        bat_cap=$(< "$bat_f")
        bat_status=$(< "${bat_f%capacity}status" 2>/dev/null)
        goto $r 1; clrl
        if [[ "$bat_status" == "Charging" ]]; then
            printf "   ${DIM}bat   ${RST}${GRN}%d%%${RST}${DIM}  charging${RST}" "$bat_cap"
        else
            c=$(pct_color "$bat_cap")
            printf "   ${DIM}bat   ${RST}${c}%d%%${RST}" "$bat_cap"
        fi
        (( r++ ))
    fi

    # ── vol ────────────────────────────────────────────────
    vol_raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    if [[ -n "$vol_raw" ]]; then
        vol_pct=$(awk '{printf "%d", $2 * 100}' <<< "$vol_raw")
        goto $r 1; clrl
        if [[ "$vol_raw" == *MUTED* ]]; then
            printf "   ${DIM}vol   ${RST}${RED}muted${RST}"
        else
            printf "   ${DIM}vol   ${RST}${WHT}%d%%${RST}" "$vol_pct"
        fi
        (( r++ ))
    fi

    # ── mic ────────────────────────────────────────────────
    mic_raw=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)
    if [[ -n "$mic_raw" ]]; then
        goto $r 1; clrl
        if [[ "$mic_raw" == *MUTED* ]]; then
            printf "   ${DIM}mic   ${RST}${RED}muted${RST}"
        else
            printf "   ${DIM}mic   ${RST}${GRN}on${RST}"
        fi
        (( r++ ))
    fi

    # ── blank ──────────────────────────────────────────────
    goto $r 1; clrl; (( r++ ))

    # ── net ────────────────────────────────────────────────
    if [[ -n "$NET_IF" ]]; then
        rx_now=$(< /sys/class/net/"$NET_IF"/statistics/rx_bytes 2>/dev/null) || rx_now=$rx_prev
        tx_now=$(< /sys/class/net/"$NET_IF"/statistics/tx_bytes 2>/dev/null) || tx_now=$tx_prev
        rx_rate=$(( (rx_now - rx_prev) / 1024 ))
        tx_rate=$(( (tx_now - tx_prev) / 1024 ))
        rx_prev=$rx_now; tx_prev=$tx_now
        goto $r 1; clrl
        printf "   ${DIM}net   ${RST}${CYN}↓ %d${RST}${DIM}  ↑ %d${RST}${DIM}  kb/s${RST}" "$rx_rate" "$tx_rate"
        (( r++ ))
    fi

    # ── wifi ───────────────────────────────────────────────
    if $IS_WIFI; then
        wifi_ssid=$(nmcli -g general.connection dev show "$NET_IF" 2>/dev/null | head -1)
        dbm=$(iw dev "$NET_IF" link 2>/dev/null | awk '/signal/{print int($2)}')
        goto $r 1; clrl
        if [[ -n "$wifi_ssid" && "$wifi_ssid" != "--" ]]; then
            printf "   ${DIM}wifi  ${RST}${WHT}%s${RST}" "$wifi_ssid"
            [[ -n "$dbm" ]] && (( dbm < 0 )) && printf "   ${DIM}%d dBm${RST}" "$dbm"
        else
            printf "   ${DIM}wifi  ${RST}${RED}off${RST}"
        fi
        (( r++ ))
    fi

    # ── blank ──────────────────────────────────────────────
    goto $r 1; clrl; (( r++ ))

    # ── uptime ─────────────────────────────────────────────
    up_str=$(uptime -p | sed 's/up //')
    goto $r 1; clrl
    printf "   ${DIM}up    ${RST}${DIM}%s${RST}" "$up_str"
    (( r++ ))

    # ── blank ──────────────────────────────────────────────
    goto $r 1; clrl; (( r++ ))

    # ── media ──────────────────────────────────────────────
    player_status=$(playerctl status 2>/dev/null)
    if [[ "$player_status" == "Playing" || "$player_status" == "Paused" ]]; then
        title=$(playerctl metadata title 2>/dev/null)
        artist=$(playerctl metadata artist 2>/dev/null)
        title="${title:0:$(( $(tput cols) - 12 ))}"
        artist="${artist:0:$(( $(tput cols) - 12 ))}"
        goto $r 1; clrl
        [[ "$player_status" == "Paused" ]] \
            && printf "   ${DIM}song  %s${RST}" "$title" \
            || printf "   ${DIM}song  ${RST}${WHT}%s${RST}" "$title"
        (( r++ ))
        goto $r 1; clrl
        printf "   ${DIM}by    %s${RST}" "$artist"
        (( r++ ))
    else
        goto $r 1; clrl; (( r++ ))
        goto $r 1; clrl; (( r++ ))
    fi

    goto $(( r + 1 )) 1
done
