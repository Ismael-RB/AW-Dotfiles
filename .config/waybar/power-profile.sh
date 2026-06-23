#!/bin/bash
ac_mode=$(cat /etc/alienware-fan/ac_mode 2>/dev/null || echo "normal")
case "$ac_mode" in
    low)    echo "󰌪" ;;
    normal) echo "󰾅" ;;
    gaming) echo "󱐋" ;;
    *)      echo "󰾅" ;;
esac
