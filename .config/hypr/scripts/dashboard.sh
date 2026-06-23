#!/bin/bash
# Dashboard para workspace 1.
# Layout: reloj centrado arriba · live-stats abajo-izquierda · cava abajo-derecha
# Requiere: tmux, tty-clock, cava

SESSION="dashboard"
TMUX_CONF="$HOME/.config/tmux/dashboard.conf"

# Si ya hay una sesión corriendo, solo adjuntarse
if tmux has-session -t "$SESSION" 2>/dev/null; then
    exec tmux attach-session -t "$SESSION"
fi

tmux -f "$TMUX_CONF" new-session -d -s "$SESSION"

# ── Pane 0 (arriba): reloj ─────────────────────────────────
tmux send-keys -t "$SESSION:0.0" "tty-clock -c -C 7 -s -b -n" Enter

# ── Split vertical: 55% abajo para fastfetch + cava ────────
tmux split-window -v -t "$SESSION:0.0" -p 55

# ── Split horizontal: derecha 58% para cava ────────────────
tmux split-window -h -t "$SESSION:0.1" -p 58

# ── Pane 1 (abajo-izquierda): stats en vivo ────────────────
tmux send-keys -t "$SESSION:0.1" "~/.config/hypr/scripts/live-stats.sh" Enter

# ── Pane 2 (abajo-derecha): cava (se relanza si se cierra) ─
tmux send-keys -t "$SESSION:0.2" "while true; do cava; sleep 1; done" Enter

# Foco en el reloj
tmux select-pane -t "$SESSION:0.0"

exec tmux attach-session -t "$SESSION"
