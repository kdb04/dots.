#!/bin/bash
DAY=$(date +%-d)
case $DAY in
  1|21|31) SUFFIX="st" ;;
  2|22)    SUFFIX="nd" ;;
  3|23)    SUFFIX="rd" ;;
  *)       SUFFIX="th" ;;
esac
DATE=$(date +"%A, %B %-d")
sketchybar --set date label="${DATE}${SUFFIX}"
