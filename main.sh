#!/bin/bash

ICON="/usr/share/icons/Yaru/scalable/status/battery-level-80-charging-symbolic.svg"
trap exit_handler EXIT

function exit_handler {
	set +u
	test -n "${TEMP}" && test -f "${TEMP}" && rm "${TEMP}"
	exit $1
}

set -euo pipefail

declare -i charge=$(cat /sys/class/power_supply/BAT0/capacity)

if [ $charge -ge 85 ]; then
	DISPLAY=:0.0 notify-send -i "$ICON" "Importante" "Carga en $charge %"
fi



