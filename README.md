# Battery charge limiter for Apple Silicon Macbook devices

<img width="300px" align="right" src="./screenshots/tray.png"/>This tool makes it possible to keep a chronically plugged in Apple Silicon Macbook at `80%` battery, since that will prolong the longevity of the battery. It is free and open-source and will remain that way.

> **About this fork:** it is fully offline. All network calls from the original
> project have been removed: no auto-updates, no version checks, no telemetry.
> The app and CLI never contact anything — update them yourself by pulling this
> repo and rerunning `./setup.sh`.

> Want to know if this tool does anything or is just a placebo? Read [this excellent article](https://batteryuniversity.com/article/bu-808-how-to-prolong-lithium-based-batteries). TL;DR: keep your battery cool, keep it at 80% when plugged in, and discharge it as shallowly as feasible.

### Requirements

This is an app for Apple Silicon Macs. It will not work on Intel macs. Do you have an older Mac? Consider the free version of the [Al Dente](https://apphousekitchen.com/) software package. It is a good alternative and has a premium version with many more features.

### Installation

This fork does not ship prebuilt apps and does not install over the network. Install from a clone of this repo:

- Option 1: the command line interface — `git clone https://github.com/michalkolek/battery.git && cd battery && ./setup.sh` (see the CLI section below)
- Option 2: the menu bar GUI — install the CLI first, then build the app from source as described in "Building the GUI app from source" below

The first time you run the setup, it will ask for your administrator password so it can install the needed components. Please note that the app:

- Discharges your battery until it reaches 80%, **even when plugged in**
- Disables charging when your battery is above 80% charged
- Enables charging when your battery is under 80% charged
- Keeps the limit engaged even after rebooting
- Keeps the limit engaged even after closing the tray app
- Also automatically installs the `battery` command line tool. If you want a custom charging percentage, the CLI is the only way to do that.

Do you have questions, comments, or feature requests? [Open an issue here](https://github.com/michalkolek/battery/issues).

---

## 🖥 Command-line version

> If you don't know what a "command line" is, ignore this section. You don't need it.

The GUI app uses a command line tool under the hood. In this fork the CLI is installed from the local repository instead of being downloaded.

The CLI is used for managing the battery charging status for Apple Silicon Macbooks. Can be used to enable/disable the Macbook from charging the battery when plugged into power.

### Installation

Install the CLI from a clone of this repo (nothing is downloaded):

```bash
git clone https://github.com/michalkolek/battery.git && cd battery && ./setup.sh
```

This will:

1. Install the precompiled `smc` tool from this repo (built from the [hholtmann/smcFanControl](https://github.com/hholtmann/smcFanControl.git) repository) to `/usr/local/co.palokaj.battery`
2. Install the `battery` script there too, with a `/usr/local/bin/battery` symlink for your PATH
3. Configure `sudo` so the background limiter runs without a password

To update later: `git pull && ./setup.sh` (or `./update.sh` to only refresh the background script).

### Usage

Example usage:

```shell
# This will enable charging when your battery dips under 80, and disable it when it exceeds 80
battery maintain 80

# This will maintain your battery between 70-80%, letting it rest in that range
battery maintain 70-80
```

After running a command like `battery charging off` you can verify the change visually by looking at the battery icon:

![Battery not charging](./screenshots/not-charging-screenshot.png)

After running `battery charging on` you will see it change to this:

![Battery charging](./screenshots/charging-screenshot.png)

For help, run `battery` without parameters:

```
Battery CLI utility v1.0.1

Usage:

  battery status
    output battery SMC status, % and time remaining

  battery maintain LEVEL[1-100,stop] or RANGE[lower-upper]
    reboot-persistent battery level maintenance: turn off charging above, and on below a certain value
    eg: battery maintain 80           # maintain at 80%
    eg: battery maintain 70-80        # maintain between 70-80%
    eg: battery maintain stop

  battery charging SETTING[on/off]
    manually set the battery to (not) charge
    eg: battery charging on

  battery adapter SETTING[on/off]
    manually set the adapter to (not) charge even when plugged in
    eg: battery adapter off

  battery calibrate
    calibrate the battery by discharging it to 15%, then recharging it to 100%, and keeping it there for 1 hour

  battery charge LEVEL[1-100]
    charge the battery to a certain percentage, and disable charging when that percentage is reached
    eg: battery charge 90

  battery discharge LEVEL[1-100]
    block power input from the adapter until battery falls to this level
    eg: battery discharge 90

  battery visudo
    ensure you don't need to call battery with sudo
    This is already used in the setup script, so you should't need it.

  battery update
    not needed in this fork: run 'git pull && ./setup.sh' in the repo

  battery reinstall
    not needed in this fork: run './setup.sh' in the repo

  battery uninstall
    enable charging, remove the smc tool, and the battery script
```

## Building the GUI app from source

The GUI lives in `./app`. To build it locally:

```bash
cd app
npm install
npm run build
```

Because local builds are not signed with an Apple Developer certificate,
macOS 15 (Sequoia) may refuse to open the freshly built app with an
"app is damaged and can't be opened" error. This is not corruption — macOS is
rejecting the signature. Fix it by re-signing the app ad-hoc before launching:

```bash
# electron-builder leaves the app at app/dist/mac-arm64/battery.app
cp -R app/dist/mac-arm64/battery.app /tmp/BatteryFixed.app
xattr -cr /tmp/BatteryFixed.app
codesign --force --deep --sign - /tmp/BatteryFixed.app
rm -rf /Applications/Battery.app
mv /tmp/BatteryFixed.app /Applications/Battery.app
open /Applications/Battery.app
```

Repeat the three `cp`/`xattr`/`codesign` steps after every rebuild, since each
new build is unsigned again. (Ad-hoc signing only makes the app run on your own
Mac; it is not enough for distributing to others.)

## FAQ & Troubleshooting

### Why does this exist?

I was looking at the Al Dente software package for battery limiting, but I found the [license too limiting](https://github.com/davidwernhart/AlDente/discussions/558) for a poweruser like myself.

I would actually have preferred using Al Dente, but decided to create a command-line utility to replace it as a side-project on holiday. A colleague mentioned they would like a GUI, so I spend a few evenings setting up an Electron app. And voila, here we are.

### "It's not working"

If you used one of the earlier versions of the `battery` utility, you may run into [path/permission issues](https://github.com/michalkolek/battery/issues/8). This is not your fault but mine. To fix it:

```
sudo rm -rf ~/.battery
binfolder=/usr/local/bin
sudo rm -v "$binfolder/smc" "$binfolder/battery"
```

Then reopen the app and things should work. If not, [open an issue](https://github.com/michalkolek/battery/issues/new/choose) and I'll try to help you fix it.

### What distinguishes this project from Optimized Charging?

Optimized Charging, a feature that is built into MacOS, aims to ensure the longevity and health of your battery. It does so by "delaying charging the battery past 80% when it predicts that you’ll be plugged in for an extended period of time, and aims to charge the battery before you unplug," as explained in [Apple's user guide](https://support.apple.com/en-ca/guide/mac-help/mchlfc3b7879/mac#:~:text=Optimized%20Battery%20Charging%3A%20To%20reduce,the%20battery%20before%20you%20unplug.).

Additionally, Optimized Charging uses machine learning to decide when the battery should be held at 80%, and when it should become fully charged. If your Mac is not plugged in on a regular schedule, optimized charging will not work as intended.

This app is a similar alternative to Optimized Charging, giving the user control over when it is activated, what percentage the battery should be held at, and more.

### How do I support this project?

Do you know how to code? Open a pull-request for a feature with the label [help wanted (PR welcome)](https://github.com/michalkolek/battery/labels/help%20wanted%20%28PR%20welcome%29).

Do you have an awesome feature idea? [Add a feature request](https://github.com/michalkolek/battery/issues/new/choose)
