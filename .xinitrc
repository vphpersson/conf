#!/bin/bash

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto

[[ -f ~/.Xresources ]] && xrdb -merge -I "$HOME" ~/.Xresources
[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap
xbindkeys
unclutter &

while true; do
	DATETIME="$(date +"%A %Y.%m.%d %H:%M")"
	VOLUME="$(amixer sget 'Master' | sed -n -E -e 's/^  Mono: Playback [[:digit:]]{1,2} \[([[:digit:]]{1,2})%\] \[-[[:digit:]]{1,2}\.[[:digit:]]{2}dB\] \[(on|off)\]$/\2 \1/p' | sed -e 's/on//' -e 's/off/M/')"
	BATTERY_STATE="$(acpi --battery | sed -n -E 's/^Battery 0: (Discharging|Charging|Not charging), ([[:digit:]]{1,2}%), ([[:digit:]]{2}:[[:digit:]]{2}):[[:digit:]]{2} (remaining|until charged)$/\2 [\3]/p')"
	xsetroot -name "${VOLUME} | ${DATETIME} | ${BATTERY_STATE}"
  sleep '0.4s'
done & 

exec dwm

