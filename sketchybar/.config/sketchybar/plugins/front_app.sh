#!/bin/bash
# Front application plugin - shows currently focused app

if [ "$SENDER" = "front_app_switched" ]; then
    sketchybar --set "$NAME" label="$INFO"
fi
