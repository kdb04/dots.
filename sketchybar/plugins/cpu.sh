#!/bin/bash

CPU=$(top -l 1 | grep "CPU usage" | awk '{print int($3 + $5)}')

sketchybar --set "$NAME" label="${CPU}%"
