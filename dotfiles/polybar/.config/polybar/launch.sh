#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# MAIN_MONITOR=HDMI-1-0
# MAIN_MONITOR=eDP-1
# MAIN_MONITOR=eDP1
# MAIN_MONITOR=DP-1-0

MAIN_MONITORS=(eDP-1-1 eDP-1 eDP1)

# Launch primary bar
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    # check if $m is in MAIN_MONITORS
    if [[ " ${MAIN_MONITORS[@]} " =~ " ${m} " ]]; then
      MONITOR=$m polybar primary &
    # else
    #   MONITOR=$m polybar secondary &
    fi
  done
fi

echo "Bars launched..."
