#!/bin/bash
ACTIVE=$(ipconfig getsummary en0 | awk '/LinkStatusActive/{print $3}')
if [ "$ACTIVE" = "TRUE" ]; then
  sketchybar --set wifi label="󰤨 Connected"
else
  sketchybar --set wifi label="󰤭 Not Connected"
fi
