#!/bin/bash
# WiFi plugin

source "$CONFIG_DIR/colors.sh"

WIFI_SSID="$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I 2>/dev/null | awk -F': ' '/ SSID/{print $2}')"

if [ -z "$WIFI_SSID" ]; then
    sketchybar --set "$NAME" \
        icon="󰤭" \
        icon.color="$RED" \
        label="Disconnected"
else
    sketchybar --set "$NAME" \
        icon="" \
        icon.color="$SAPPHIRE" \
        label="$WIFI_SSID"
fi
