#!/bin/bash

ICON="/usr/share/icons/Yaru/scalable/status/battery-level-80-charging-symbolic.svg"
trap exit_handler EXIT

function exit_handler {
	set +u
	test -n "${TEMP}" && test -f "${TEMP}" && rm "${TEMP}"
	exit $1
}

set -euo pipefail

SLEEPTIME=60

function transition_to_waiting_power_AC {
	echo ESPERANDO CONECCION DE CARGADOR
	STATE=waiting_power_AC
}

function transition_to_monitoring_charge {
	echo MONITOREANDO CARGA
	STATE=monitoring_charge
}

function waiting_power_AC {
	#echo ========================
	#upower -i /org/freedesktop/UPower/devices/line_power_AC
	#echo ======================
	local ischarging=$(upower -i /org/freedesktop/UPower/devices/line_power_AC|fgrep "online:"|awk '{print $2}')
	if [ $ischarging = "yes" ];then
		echo CARGADOR CONECTADO
		STATE=transition_to_monitoring_charge
	else
		sleep $SLEEPTIME
	fi
}

function monitoring_charge {
	local ischarging=$(upower -i /org/freedesktop/UPower/devices/line_power_AC|fgrep "online:"|awk '{print $2}')

	if [ $ischarging = "yes" ];then
		charge=$(cat /sys/class/power_supply/BAT0/capacity)
		if [ $charge -ge 85 ];then
			DISPLAY=:0.0 notify-send -i "$ICON" "Importante" "Carga en $charge %"
			paplay /usr/share/sounds/Yaru/stereo/device-added.oga 2> /dev/null
		fi
	else
		STATE=transition_to_waiting_power_AC
	fi
	sleep $SLEEPTIME
}

STATE=transition_to_waiting_power_AC

while [ 1 ]
do
	$STATE
done

exit 0
