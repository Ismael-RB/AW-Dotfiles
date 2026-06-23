#!/bin/bash
mode=$(cat /etc/alienware-fan/ac_mode 2>/dev/null || echo "normal")
case "$mode" in
    gaming) echo "󰓅" ;;
    low)    echo "󰾆" ;;
    *)      echo "󰾅" ;;
esac
