#!/bin/bash

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false

usage() {
    echo "Usage: $0 [--dry-run]"
    echo "  --dry-run  Show what would be installed without doing anything"
    exit 0
}

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --help|-h) usage ;;
        *) echo "Unknown argument: $arg"; usage ;;
    esac
done

run() {
    if $DRY_RUN; then
        echo "[dry-run] $*"
    else
        "$@"
    fi
}

backup_and_copy() {
    local src="$1"
    local dst="$2"

    if [ -e "$dst" ] && ! $DRY_RUN; then
        mv "$dst" "${dst}.bak"
        echo "  backed up: ${dst} → ${dst}.bak"
    fi

    run mkdir -p "$(dirname "$dst")"
    run cp -r "$src" "$dst"
    echo "  installed: $dst"
}

section() {
    echo ""
    echo "── $1"
}

# ── .config ──────────────────────────────────────────────────────────────────

section "User configs → ~/.config/"

for src in "$DOTFILES"/.config/*/; do
    name="$(basename "$src")"
    dst="$HOME/.config/$name"

    if [ "$name" = "fish" ]; then
        # Copy fish dir but skip fish_variables (machine-specific)
        run mkdir -p "$dst"
        for item in "$src"*; do
            [ "$(basename "$item")" = "fish_variables" ] && continue
            run cp -r "$item" "$dst/"
        done
        echo "  installed: $dst (skipped fish_variables)"
        continue
    fi

    if [ "$name" = "pipewire" ]; then
        continue  # handled separately in the PipeWire EQ section
    fi

    backup_and_copy "$src" "$dst"
done

run cp "$DOTFILES/.config/starship.toml" "$HOME/.config/starship.toml"
echo "  installed: $HOME/.config/starship.toml"

# ── PipeWire EQ ──────────────────────────────────────────────────────────────

section "PipeWire EQ"

EQ_SRC="$DOTFILES/.config/pipewire/filter-chain.conf.d/speakers-eq.conf"
EQ_DST="$HOME/.config/pipewire/filter-chain.conf.d/speakers-eq.conf"

run mkdir -p "$(dirname "$EQ_DST")"
run cp "$EQ_SRC" "$EQ_DST"
echo "  installed: $EQ_DST"

if ! $DRY_RUN; then
    systemctl --user restart pipewire && echo "  restarted: pipewire"
else
    echo "[dry-run] systemctl --user restart pipewire"
fi

# ── Scripts ───────────────────────────────────────────────────────────────────

section "Making scripts executable"

find "$HOME/.config/hypr/scripts" "$HOME/.config/waybar" \
    -name "*.sh" 2>/dev/null | while read -r f; do
    run chmod +x "$f"
    echo "  chmod +x: $f"
done

# ── Fan daemon ────────────────────────────────────────────────────────────────

section "Fan & CPU daemon + awm (requires sudo)"

if $DRY_RUN; then
    echo "[dry-run] sudo cp system/alienware-fan/alienware-fan /usr/local/bin/"
    echo "[dry-run] sudo chmod +x /usr/local/bin/alienware-fan"
    echo "[dry-run] sudo cp system/alienware-fan/alienware-fan.service /etc/systemd/system/"
    echo "[dry-run] sudo systemctl enable --now alienware-fan"
    echo "[dry-run] sudo cp system/awm /usr/local/bin/awm"
    echo "[dry-run] sudo chmod +x /usr/local/bin/awm"
    echo "[dry-run] sudo cp system/auto-mode/auto-mode /usr/local/bin/"
    echo "[dry-run] sudo chmod +x /usr/local/bin/auto-mode"
    echo "[dry-run] sudo cp system/auto-mode/auto-mode.service /etc/systemd/system/"
    echo "[dry-run] sudo systemctl enable --now auto-mode"
else
    sudo cp "$DOTFILES/system/alienware-fan/alienware-fan" /usr/local/bin/
    sudo chmod +x /usr/local/bin/alienware-fan
    sudo cp "$DOTFILES/system/alienware-fan/alienware-fan.service" /etc/systemd/system/
    sudo systemctl enable --now alienware-fan
    echo "  enabled:   alienware-fan.service"
    sudo cp "$DOTFILES/system/awm" /usr/local/bin/awm
    sudo chmod +x /usr/local/bin/awm
    echo "  installed: /usr/local/bin/awm"
    sudo cp "$DOTFILES/system/auto-mode/auto-mode" /usr/local/bin/
    sudo chmod +x /usr/local/bin/auto-mode
    sudo cp "$DOTFILES/system/auto-mode/auto-mode.service" /etc/systemd/system/
    sudo systemctl enable --now auto-mode
    echo "  enabled:   auto-mode.service"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "Done. Reload Hyprland or log out to apply all changes."
$DRY_RUN && echo "(dry-run — nothing was written)"
