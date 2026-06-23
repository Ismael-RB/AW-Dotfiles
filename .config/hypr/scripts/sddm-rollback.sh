#!/bin/bash
# Rollback de emergencia para el tema SDDM.
# Ejecutar como root o con sudo si es necesario.
# Uso: sudo bash ~/.config/hypr/scripts/sddm-rollback.sh

set -e

echo "[sddm-rollback] Eliminando tema hypr-wal..."
rm -rf /usr/local/share/sddm/themes/hypr-wal

echo "[sddm-rollback] Eliminando sddm.conf.d/theme.conf..."
rm -f /etc/sddm.conf.d/theme.conf

echo "[sddm-rollback] SDDM vuelve a su estado original (sin tema custom)."
echo "[sddm-rollback] Listo. Reinicia sddm si es necesario: sudo systemctl restart sddm"
