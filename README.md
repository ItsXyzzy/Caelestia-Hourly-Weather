# Caelestia Weather Hourly Forecast

An hourly forecast for the Weather tab of the [Caelestia](https://github.com/caelestia-dots/shell) dashboard:

- A temperature graph for the whole week that you scroll with arrows, with the times, weather icons and rain chance underneath
- A collapse button, and a choice of whether it starts collapsed or expanded
- A one-line summary of the day, like "Cloudy now, rain from 15:00, high of 17°"
- A graph scale that looks a few pages around the view, so it doesn't jump as you scroll

It uses the data the Weather tab already loads, so there are no extra requests.

## Install

```bash
git clone <this repo>
cd <folder>
./install.sh
```

It asks whether the hourly forecast should start expanded or collapsed when the tab opens. Skip the question with an option:

```bash
./install.sh --hourly collapsed
```

Run it again any time to change it. Then restart the shell. Don't use sudo. It installs into `~/.config/quickshell/caelestia`, copying the system config there first if you don't have one, so package updates won't undo it.

## Uninstall

```bash
./uninstall.sh
```

## Good to know

- It replaces the stock `WeatherTab.qml`. The original is saved as `WeatherTab.qml.bak`. If you've customised the Weather tab, back it up first.
- Needs a recent Caelestia. The installer checks and tells you what's missing instead of installing something that won't load.
- Only tested on Arch with Hyprland.

## Manual install

Copy `qml/modules/dashboard/WeatherTab.qml` to `~/.config/quickshell/caelestia/modules/dashboard/`. Optional: near the top of the file, set `startCollapsed` to `true` to start with the hourly forecast collapsed.

## License

GPL-3.0, since this builds on Caelestia's own code.
