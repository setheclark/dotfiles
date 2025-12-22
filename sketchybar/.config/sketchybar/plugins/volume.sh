#!/bin/bash
# Volume plugin

source "$HOME/.config/sketchybar/colors.sh"

VOLUME="$(osascript -e 'output volume of (get volume settings)')"

case "$VOLUME" in
    100) ICON="󰕾" ;;
    [7-9][0-9]) ICON="󰕾" ;;
    [4-6][0-9]) ICON="󰖀" ;;
    [1-3][0-9]) ICON="󰕿" ;;
    [0-9]) ICON="󰕿" ;;
    0) ICON="󰝟" ;;
    *) ICON="󰕾" ;;
esac

sketchybar --set "$NAME" \
    icon="$ICON" \
    label="${VOLUME}%"
