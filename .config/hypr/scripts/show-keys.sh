#!/bin/bash
printf '\033[2J\033[H'
printf '\033[2m  atajos — todos los modificadores\033[0m\n\n'

hyprctl binds -j 2>/dev/null | jq -r '
  .[] |
  select(.mouse == false) |
  {
    mod: (
      [
        if (.modmask / 64 | floor) % 2 == 1 then "SUPER" else empty end,
        if (.modmask / 8  | floor) % 2 == 1 then "ALT"   else empty end,
        if (.modmask / 4  | floor) % 2 == 1 then "CTRL"  else empty end,
        if (.modmask / 1  | floor) % 2 == 1 then "SHIFT" else empty end
      ] | join("+")
      | if . == "" then "─" else . end
    ),
    key: .key,
    act: (if .dispatcher == "exec"
          then (.arg | split(" ") | map(select(startswith("~") or (test("^[a-zA-Z]") and (contains("/") | not)))) | first // (.arg | split(" ") | last | split("/") | last))
          else "\(.dispatcher) \(.arg)" end)
  } |
  "\(.mod)\t\(.key)\t\(.act)"
' | sort -t$'\t' -k1,1 -k2,2 | uniq | \
  awk -F'\t' '{printf "  \033[2m%-20s\033[0m  \033[1m%-16s\033[0m  %s\n", $1, $2, $3}'

printf '\n\033[2m  q · cerrar\033[0m\n'
read -rsn1
