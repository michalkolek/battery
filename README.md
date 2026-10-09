# Battery — offline charge limiter for Apple Silicon MacBooks

A fork of [actuallymentor/battery](https://github.com/actuallymentor/battery) that keeps a chronically plugged-in Apple Silicon MacBook at a charge limit (80% by default) to prolong battery longevity. Free and open-source (MIT), and it stays that way.

> Want to know whether limiting charge does anything or is just a placebo? Read [this batteryuniversity article](https://batteryuniversity.com/article/bu-808-how-to-prolong-lithium-based-batteries). TL;DR: keep your battery cool, keep it around 80% when plugged in, and discharge it as shallowly as feasible.

## What this fork changes

**This is the fully-offline version: no component ever reaches out to the internet on its own.**

The original project phones home in a few places that are easy to miss:

| Original behaviour | This fork |
| --- | --- |
| Menu bar app pings `unidentifiedanalytics.web.app` on every launch (counts unique visitor IPs) | removed — no telemetry |
| Menu bar app checks connectivity by requesting `icanhazip.com` (an IP-disclosure probe) | removed |
| CLI checks GitHub for a newer script, then downloads and runs `battery.sh`/`setup.sh`/`update.sh` via `curl \| bash` | removed — `battery update`/`reinstall` only do local maintenance and point at this repo |
| `setup.sh` downloads the upstream repo zip from GitHub | installs from the local clone instead |
| GUI auto-updates itself in the background from GitHub releases (`update-electron-app`) | removed |

Nothing here downloads or uploads anything at runtime. The only network code left is menu links that open your browser when **you** click them, and the optional `--pull` flag on `./update.sh`, which runs `git pull` only when you ask for it.

Why go offline? Auto-updating a tool that holds a passwordless `sudo` entry for writing battery firmware values is a supply-chain risk you shouldn't accept by default: with network updates, whoever controls the upstream repo controls what runs as root on your Mac. Here, every change is something you pulled and installed deliberately.

### Requirements

Apple Silicon Macs only (no Intel). Older Macs should look at [AlDente](https://apphousekitchen.com/).

## Installing the command line tool

```bash
git clone https://github.com/michalkolek/battery.git && cd battery && ./setup.sh
```

This asks for your administrator password once, then:

1. Installs the precompiled `smc` tool from this repo (built from [hholtmann/smcFanControl](https://github.com/hholtmann/smcFanControl.git)) and the `battery` script into `/usr/local/co.palokaj.battery` (root-owned)
2. Symlinks `/usr/local/bin/battery` so the command is on your PATH
3. Configures `sudo` so battery commands run without a password

The utility:

- Disables charging when your battery is above your limit
- Enables charging when it dips below
- Keeps the limit engaged across reboots and after closing the GUI

## Using the command line tool

```bash
# Maintain between 70-80%
battery maintain 70-80

# Maintain at 80%
battery maintain 80

# Check status / stop / get help
battery status
battery maintain stop
battery
```

Other commands: `charging on/off`, `adapter on/off`, `charge LEVEL`, `discharge LEVEL`, `calibrate`, `logs`, `uninstall`. Run `battery` without parameters for full help.

## Installing the menu bar GUI

The GUI wraps the CLI. In this fork there is no prebuilt app to download — you build it locally:

```bash
cd app
npm install
npm run build          # builds, and automatically ad-hoc re-signs the app
npm run install:local  # moves it into /Applications and launches it
```

(or just `npm run rebuild` to do both steps).

The build's `afterPack` hook re-signs the app automatically: macOS 15 (Sequoia) kills locally built, unsigned Electron apps with an "app is damaged and can't be opened" error, and ad-hoc signing is what fixes it. You'll only ever need to do it by hand if you copy the `.app` out of a `node_modules` or downloaded folder:

```bash
xattr -cr Battery.app
codesign --force --deep --sign - Battery.app
```

The first time the app opens it may ask for your password to install the CLI components; if it complains, run `./setup.sh` from the repo as described above.

## Updating this fork

Nothing updates itself, by design:

```bash
cd battery
git pull
./setup.sh            # refresh the CLI (and visudo config)
cd app && npm run rebuild   # rebuild the GUI, if you use it
```

`./update.sh` is a lighter alternative that only refreshes the installed background script from the local clone (`./update.sh --pull` does a `git pull` first).

## Troubleshooting

### "App is damaged and can't be opened"

The re-signed app lost its signature somehow (moved between machines, partially updated, etc.). Re-apply it:

```bash
codesign --force --deep --sign - /Applications/battery.app
```

Or just rerun `npm run rebuild` in `app/`.

### Permission/path issues from old versions

```bash
sudo rm -rf ~/.battery
binfolder=/usr/local/bin
sudo rm -v "$binfolder/smc" "$binfolder/battery"
```

then rerun `./setup.sh`.

## Credits

- Original project and all the SMC reverse-engineering: [actuallymentor/battery](https://github.com/actuallymentor/battery) and its contributors
- `smc` tool: [hholtmann/smcFanControl](https://github.com/hholtmann/smcFanControl)
- This fork: same MIT license, see `LICENSE`
