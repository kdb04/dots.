#!/bin/bash
PERCENT=$(pmset -g batt | grep -o '[0-9]*%' | head -1 | tr -d '%')
if [ -z "$PERCENT" ]; then exit 0; fi

if [ "$PERCENT" -ge 75 ]; then BAR="▰▰▰▰"
elif [ "$PERCENT" -ge 50 ]; then BAR="▰▰▰▱"
elif [ "$PERCENT" -ge 25 ]; then BAR="▰▰▱▱"
elif [ "$PERCENT" -ge 10 ]; then BAR="▰▱▱▱"
else BAR="▱▱▱▱"
fi

sketchybar --set battery label="$BAR $PERCENT%"
