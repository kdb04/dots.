#!/bin/bash

TEMP=$(curl -s "wttr.in/?format=%t" | tr -d '+')

sketchybar --set "$NAME" label="$TEMP"
