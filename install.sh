#!/usr/bin/env bash
#
# Caelestia weather hourly forecast: installer
#
# Installs into your user config (~/.config/quickshell/caelestia). No sudo needed,
# and package updates won't overwrite it.
#
# Usage: ./install.sh [--hourly expanded|collapsed]
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_DIR="${CAELESTIA_SYSTEM_DIR:-/etc/xdg/quickshell/caelestia}"
XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET="$XDG_CONFIG/quickshell/caelestia"
SRC="$SCRIPT_DIR/qml/modules/dashboard/WeatherTab.qml"
WEATHER="$TARGET/modules/dashboard/WeatherTab.qml"

HOURLY=""

usage() {
    cat <<'EOF'
Usage: ./install.sh [--hourly expanded|collapsed]

  --hourly   Whether the hourly forecast starts expanded (default) or collapsed
             when the Weather tab opens. It can always be toggled with the button.

Without options it asks, when run in a terminal. Run it again any time to change it.
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --hourly)
            [ $# -ge 2 ] || { echo "--hourly needs a value."; exit 1; }
            HOURLY="$2"; shift 2 ;;
        --hourly=*) HOURLY="${1#*=}"; shift ;;
        -h|--help)  usage; exit 0 ;;
        *)          echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

case "$HOURLY" in ""|expanded|collapsed) ;; *) echo "--hourly must be 'expanded' or 'collapsed'."; exit 1 ;; esac

if [ "$EUID" -eq 0 ]; then
    echo "Don't run this with sudo. It installs into your user config."
    exit 1
fi

# Check everything before writing anything.
if [ -d "$TARGET" ]; then ROOT="$TARGET"; else ROOT="$SYSTEM_DIR"; fi

if [ ! -f "$ROOT/modules/dashboard/WeatherTab.qml" ]; then
    echo "Couldn't find Caelestia's Weather tab at $ROOT/modules/dashboard/WeatherTab.qml."
    echo "Install caelestia-shell first, or set CAELESTIA_SYSTEM_DIR."
    exit 1
fi

missing=()
grep -qs "WeatherTab" "$ROOT/modules/dashboard/Content.qml" || missing+=("a dashboard that uses WeatherTab")
grep -qs "hourlyForecast" "$ROOT/services/Weather.qml" || missing+=("Weather.hourlyForecast (hourly data in the Weather service)")
grep -qs "function formatTemp" "$ROOT/services/Weather.qml" || missing+=("Weather.formatTemp")
grep -qs "twelveHourClock" "$ROOT/services/Weather.qml" || missing+=("Units.twelveHourClock")
grep -qs "function percent" "$ROOT/utils/Strings.qml" || missing+=("Strings.percent")
{ grep -qs "EmphasizedLarge" "$ROOT/components/Anim.qml" && grep -qs "SlowEffects" "$ROOT/components/Anim.qml"; } || missing+=("the EmphasizedLarge and SlowEffects animation types")
[ -f "$ROOT/components/StyledClippingRect.qml" ] || missing+=("components/StyledClippingRect.qml")
grep -rqs "Caelestia.I18n" "$ROOT/modules" "$ROOT/services" || missing+=("the Caelestia.I18n module")
if [ "${#missing[@]}" -gt 0 ]; then
    echo "This needs a newer Caelestia. Missing:"
    printf '  - %s\n' "${missing[@]}"
    echo "Nothing was changed."
    exit 1
fi

# Ask when run in a terminal, otherwise use the default.
if [ -z "$HOURLY" ] && [ -t 0 ]; then
    echo
    echo "When the Weather tab opens, the hourly forecast should be:"
    echo "  1) Expanded  (default)"
    echo "  2) Collapsed (open it with the arrow button)"
    read -rp "Choose [1/2]: " reply || reply=""
    case "$reply" in 2) HOURLY=collapsed ;; *) HOURLY=expanded ;; esac
fi
HOURLY="${HOURLY:-expanded}"

echo
echo "Installing the weather hourly forecast..."

# A user copy takes priority over /etc/xdg and survives package updates.
if [ ! -d "$TARGET" ]; then
    echo "-> Copying $SYSTEM_DIR to $TARGET"
    mkdir -p "$XDG_CONFIG/quickshell"
    cp -r "$SYSTEM_DIR" "$TARGET"
fi

# Only the first backup is kept, so running the installer twice never overwrites the original.
if [ ! -f "$WEATHER.bak" ]; then
    cp "$WEATHER" "$WEATHER.bak"
fi
cp "$SRC" "$WEATHER"

if [ "$HOURLY" = "collapsed" ]; then val=true; else val=false; fi
sed -i "s/readonly property bool startCollapsed: [a-z]*/readonly property bool startCollapsed: $val/" "$WEATHER"

if grep -q "startCollapsed: $val" "$WEATHER"; then
    echo "  ok:   WeatherTab.qml (hourly starts $HOURLY)"
else
    echo "  warn: couldn't apply the option. Edit startCollapsed near the top of WeatherTab.qml." >&2
fi

echo
echo "Done. Restart the shell (log out and back in, or stop it and run 'caelestia shell')."
echo "To change the option, run ./install.sh again. To undo: ./uninstall.sh"
