#!/bin/bash
# Workspace/space indicator plugin

source "$HOME/.config/sketchybar/colors.sh"

if [ "$SELECTED" = "true" ]; then
    sketchybar --set "$NAME" \
        background.color="$ACCENT" \
        icon.color="$CRUST"
else
    sketchybar --set "$NAME" \
        background.color="$SURFACE0" \
        icon.color="$TEXT"
fi
