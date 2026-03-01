#!/bin/bash
SPACE_ID=$1
ICON_DIR="$HOME/.config/sketchybar/icons"

FOCUSED=$(yabai -m query --spaces --space $SPACE_ID 2>/dev/null | python3 -c "
import sys, json
s = json.load(sys.stdin)
print('true' if s.get('has-focus') else 'false')
" 2>/dev/null)

FIRST_APP=$(yabai -m query --windows --space $SPACE_ID 2>/dev/null | python3 -c "
import sys, json, re
windows = json.load(sys.stdin)
apps = [w['app'] for w in windows if w['app'] and not w['is-minimized']]
if apps:
    app = re.sub(r'[^\x20-\x7E]', '', apps[0].strip())
    app = app.lower().replace(' ', '-')
    print(app)
" 2>/dev/null)

ICON_FILE="$ICON_DIR/${FIRST_APP}.png"

if [ "$FOCUSED" = "true" ]; then
  BG=0xdde8a070
  BORDER=0xffe8c49a
else
  BG=0x55c47a3a
  BORDER=0x88e8a070
fi

if [ -f "$ICON_FILE" ]; then
  sketchybar --set space.$SPACE_ID \
    background.color=$BG \
    background.border_color=$BORDER \
    background.drawing=on \
    background.image="$ICON_FILE" \
    background.image.drawing=on \
    background.image.scale=0.85 \
    background.image.padding_left=10 \
    background.image.padding_left=10 \
    background.image.padding_left=5 \
    icon.drawing=off \
    label.drawing=off \
    width=40
elif [ -n "$FIRST_APP" ]; then
  sketchybar --set space.$SPACE_ID \
    background.color=$BG \
    background.border_color=$BORDER \
    background.drawing=on \
    background.image.drawing=off \
    icon.drawing=on \
    icon.color=0xffe8c49a \
    label.drawing=off \
    width=40
else
  sketchybar --set space.$SPACE_ID width=0 background.drawing=off
fi
