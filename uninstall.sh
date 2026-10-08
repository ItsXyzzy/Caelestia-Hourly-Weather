#!/usr/bin/env bash
#
# Caelestia weather hourly forecast: uninstaller
#
# Restores the WeatherTab.qml the installer backed up.
#
# Usage: ./uninstall.sh
#
set -euo pipefail

XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET="$XDG_CONFIG/quickshell/caelestia"
WEATHER="$TARGET/modules/dashboard/WeatherTab.qml"

if [ "$EUID" -eq 0 ]; then
    echo "Don't run this with sudo. It works on your user config."
    exit 1
fi

if [ ! -d "$TARGET" ]; then
    echo "Nothing to uninstall: $TARGET doesn't exist."
    exit 0
fi

if [ -f "$WEATHER.bak" ]; then
    mv "$WEATHER.bak" "$WEATHER"
    echo "Restored the original WeatherTab.qml."
else
    echo "No backup found, so there's nothing to restore."
fi

echo
echo "Restart the shell."
echo "Your user copy at $TARGET still overrides /etc/xdg/quickshell/caelestia."
echo "To let package updates apply again, delete it: rm -rf \"$TARGET\""
